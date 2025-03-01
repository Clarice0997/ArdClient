Haven Resource 1 src �  TreeRotation.java /* Preprocessed source code */
/* $use: lib/globfx */
/* $use: lib/leaves */
/* $use: lib/svaj */

package haven.res.lib.tree;

import haven.*;
import haven.render.*;
import haven.res.lib.leaves.*;
import haven.res.lib.svaj.*;
import java.util.*;

public class TreeRotation extends GAttrib implements Gob.SetupMod {
    public final Location rot;

    public TreeRotation(Gob gob, Location rot) {
	super(gob);
	this.rot = rot;
    }

    public Pipe.Op placestate() {
	return(rot);
    }
}

src 
  TreeScale.java /* Preprocessed source code */
/* $use: lib/globfx */
/* $use: lib/leaves */
/* $use: lib/svaj */

package haven.res.lib.tree;

import haven.*;
import haven.render.*;
import haven.res.lib.leaves.*;
import haven.res.lib.svaj.*;
import java.util.*;

public class TreeScale extends GAttrib implements Gob.SetupMod {
    public final float scale;
    public final Location mod;

    public TreeScale(Gob gob, float scale) {
	super(gob);
	this.scale = scale;
	this.mod = Tree.mkscale(scale);
    }

    public Pipe.Op placestate() {
	return(mod);
    }
}

/*
 * Tree mesh IDs are of the form 0xabcd, where:
 *
 * a selects by tree "stage":
 *   0x1 selects for ordinary planted tree
 *   0x2      "      falling tree
 *   0x4      "      stump
 * b != 0 means enable mesh only under relevant seasons:
     0x1: Spring, 0x2: Summer, 0x4: Autumn, 0x8: Winter
 * c != 0 means use material (c * 4 + season) for mesh
 * d is ordinary resdat selection id, but shifted one bit to allow
 *   0 to mean always on, and inverted.
 */
src �  Tree.java /* Preprocessed source code */
/* $use: lib/globfx */
/* $use: lib/leaves */
/* $use: lib/svaj */

package haven.res.lib.tree;

import haven.*;
import haven.render.*;
import haven.res.lib.leaves.*;
import haven.res.lib.svaj.*;
import java.util.*;

public class Tree extends Sprite {
    public final float fscale;
    public final RenderTree.Node[][] parts;
    public int stage, sel;
    public LeafSpec leaves = null;
    private final Collection<RenderTree.Slot> slots = new ArrayList<>();

    public static Location mkscale(float x, float y, float z) {
	return(new Location(new Matrix4f(x, 0, 0, 0,
					 0, y, 0, 0,
					 0, 0, z, 0,
					 0, 0, 0, 1)));
    }

    public static Location mkscale(float s) {
	return(mkscale(s, s, s));
    }

    public Collection<Pair<Integer, RenderTree.Node>> lsparts(Resource res, int matsel) {
	Collection<Pair<Integer, RenderTree.Node>> rl = new ArrayList<>(16);
	for(FastMesh.MeshRes mr : res.layers(FastMesh.MeshRes.class)) {
	    int id = (mr.id < 0) ? 0 : mr.id;
	    int dmat = (id & 0xf0) >> 4;
	    if((dmat == 0) || (matsel < 0)) {
		if(mr.mat != null)
		    rl.add(new Pair<>(id, mr.mat.get().apply(mr.m)));
	    } else {
		Material.Res mat = res.layer(Material.Res.class, (dmat * 4) + matsel);
		if(mat != null)
		    rl.add(new Pair<>(id, mat.get().apply(mr.m)));
	    }
	}
	for(RenderLink.Res lr : res.layers(RenderLink.Res.class)) {
	    rl.add(new Pair<>(lr.id, lr.l.make(owner)));
	}
	return(rl);
    }

    @SuppressWarnings("unchecked")
    public RenderTree.Node[][] mkparts(Resource res, int matsel, int fl) {
	Collection<RenderTree.Node> rl[] = new Collection[3];
	for(int i = 0; i < rl.length; rl[i++] = new ArrayList<>());
	int pmask = (1 << rl.length) - 1;
	for(Pair<Integer, RenderTree.Node> part : lsparts(res, matsel)) {
	    if(((1 << (part.a & 0xf)) & fl) != 0)
		continue;
	    int dmesh = (part.a & 0xf00) >> 8;
	    if((dmesh != 0) && (matsel >= 0) && ((dmesh & (1 << matsel)) == 0))
		continue;
	    int sel = ((part.a & 0xf000) >> 12) & pmask;
	    for(int i = 0; i < rl.length; i++)
		if((sel == 0) || ((sel & (1 << i)) != 0))
		    rl[i].add(part.b);
	}
	RenderTree.Node[][] ret = new RenderTree.Node[rl.length][];
	for(int i = 0; i < ret.length; i++)
	    ret[i] = rl[i].toArray(new RenderTree.Node[0]);
	return(ret);
    }

    public static Random randoom(Gob owner) {
	Coord tc = owner.rc.floor(MCache.tilesz);
	MCache.Grid grid = owner.glob.map.getgridt(tc);
	tc = tc.sub(grid.ul);
	Random rnd = new Random(grid.id);
	rnd.setSeed(rnd.nextLong() ^ tc.x);
	rnd.setSeed(rnd.nextLong() ^ tc.y);
	return(rnd);
    }

    public static Location rndrot(Random rnd) {
	double aa = rnd.nextDouble() * Math.PI * 2;
	double ra = rnd.nextGaussian() * Math.PI / 64;
	Coord3f axis = new Coord3f((float)Math.sin(aa), (float)Math.cos(aa), 0);
	return(Location.rot(axis, (float)ra));
    }

    public static Location rndrot(Owner owner) {
	if(owner instanceof Gob)
	    return(rndrot(randoom((Gob)owner)));
	return(null);
    }

    public Tree(Owner owner, Resource res, float scale, int s, int fl) {
	super(owner, res);
	this.fscale = scale;
	if(owner instanceof Gob) {
	    Gob gob = (Gob)owner;
	    gob.setattr(new TreeRotation(gob, rndrot(gob)));
	    gob.setattr(new GobSvaj(gob));
	    if(fscale != 1.0f)
		gob.setattr(new TreeScale(gob, fscale));
	}
	parts = mkparts(res, s, fl);
	sel = s;
    }

    private static final haven.res.lib.tree.Factory deffac = new haven.res.lib.tree.Factory();
    public static Tree mksprite(Owner owner, Resource res, Message sdt) {
	/* XXX: Remove me */
	return(deffac.create(owner, res, sdt));
    }

    public void added(RenderTree.Slot slot) {
	for(RenderTree.Node p : parts[stage])
	    slot.add(p);
	slots.add(slot);
    }

    public void removed(RenderTree.Slot slot) {
	slots.remove(slot);
    }

    private Random lrand;
    private double lrate;
    public boolean tick(double dt) {
	leaves: if(leaves != null) {
	    if(lrand == null) {
		lrand = new Random();
		if(lrand.nextInt(2) == 0) {
		    leaves = null;
		    break leaves;
		}
		Random rrand = lrand;
		if(owner instanceof Gob) {
		    try {
			rrand = randoom((Gob)owner);
		    } catch(Loading l) {
			break leaves;
		    }
		}
		lrate = 0.05 + (Math.pow(rrand.nextDouble(), 0.75) * 0.95);
	    }
	    if(fscale < 0.75)
		return(false);
	    try {
		if(!slots.isEmpty() && (lrand.nextDouble() > Math.pow(lrate, dt))) {
		    Location.Chain loc = Utils.el(slots).state().get(Homo3D.loc);
		    FallingLeaves fx = FallingLeaves.get(((Gob)owner).glob);
		    Material mat = leaves.mat[lrand.nextInt(leaves.mat.length)];
		    fx.addleaf(new StdLeaf(fx, fx.onevertex(loc, leaves.mesh), mat));
		}
	    } catch(Loading e) {}
	}
	return(false);
    }
}

src �  StdLeaf.java /* Preprocessed source code */
/* $use: lib/globfx */
/* $use: lib/leaves */
/* $use: lib/svaj */

package haven.res.lib.tree;

import haven.*;
import haven.render.*;
import haven.res.lib.leaves.*;
import haven.res.lib.svaj.*;
import java.util.*;

public class StdLeaf extends FallingLeaves.Leaf {
    public final Material m;

    public StdLeaf(FallingLeaves fx, Coord3f c, Material m) {
	fx.super(c);
	this.m = m;
    }

    public Material mat() {return(m);}
}

src W  LeafSpec.java /* Preprocessed source code */
/* $use: lib/globfx */
/* $use: lib/leaves */
/* $use: lib/svaj */

package haven.res.lib.tree;

import haven.*;
import haven.render.*;
import haven.res.lib.leaves.*;
import haven.res.lib.svaj.*;
import java.util.*;

public class LeafSpec {
    public FastMesh mesh;
    public Material[] mat;
}

src   Factory.java /* Preprocessed source code */
/* $use: lib/globfx */
/* $use: lib/leaves */
/* $use: lib/svaj */

package haven.res.lib.tree;

import haven.*;
import haven.render.*;
import haven.res.lib.leaves.*;
import haven.res.lib.svaj.*;
import java.util.*;

public class Factory implements Sprite.Factory {
    public LeafSpec leaves = null;

    public Factory() {}

    public Factory(Resource ires, Object[] args) {
	this();
	for(Object argp : args) {
	    Object[] arg = (Object[])argp;
	    switch((String)arg[0]) {
	    case "leaves":
		dropleaves(ires, ((Number)arg[1]).intValue(), ires.pool.load((String)arg[2], (Integer)arg[3]));
		break;
	    }
	}
    }

    public Tree create(Sprite.Owner owner, Resource res, Message sdt) {
	int s = -1, fl = 0;
	if(!sdt.eom()) {
	    int m = sdt.uint8();
	    if((m & 0xf0) != 0)
		s = ((m & 0xf0) >> 4) - 1;
	    fl = (m & 0x0f) << 1;
	}
	float scale = sdt.eom() ? 1 : (sdt.uint8() / 100.0f);
	Tree ret = new Tree(owner, res, scale, s, fl);
	if(s == 2)
	    ret.leaves = this.leaves;
	return(ret);
    }

    public void dropleaves(Resource res, int matid, Indir<Resource> imats) {
	Resource mats = Loading.waitfor(imats);
	LeafSpec leaves = new LeafSpec();
	for(FastMesh.MeshRes mr : res.layers(FastMesh.MeshRes.class)) {
	    if(mr.mat.id == matid)
		leaves.mesh = mr.m;
	}
	if(leaves.mesh == null)
	    throw(new RuntimeException("No leaf-dropping mesh"));
	Collection<Material> m = new ArrayList<>();
	for(Material.Res mr : mats.layers(Material.Res.class))
	    m.add(mr.get());
	if(m.isEmpty())
	    throw(new RuntimeException("No leaf materials"));
	leaves.mat = m.toArray(new Material[0]);
	this.leaves = leaves;
    }

    public void dropleaves(int matid, Indir<Resource> imats) {
	dropleaves(Resource.classres(this.getClass()), matid, imats);
    }
}
code Z  haven.res.lib.tree.TreeRotation ����   4  
  	      rot Lhaven/render/Location; <init> %(Lhaven/Gob;Lhaven/render/Location;)V Code LineNumberTable 
placestate  Op InnerClasses ()Lhaven/render/Pipe$Op; 
SourceFile TreeRotation.java     haven/res/lib/tree/TreeRotation haven/GAttrib  haven/Gob$SetupMod SetupMod  haven/render/Pipe$Op (Lhaven/Gob;)V 	haven/Gob haven/render/Pipe 
tree.cjava !              	  
   +     *+� *,� �              
      
        *� �                         	   	code �  haven.res.lib.tree.TreeScale ����   4 *
  	  
  	      scale F mod Lhaven/render/Location; <init> (Lhaven/Gob;F)V Code LineNumberTable 
placestate " Op InnerClasses ()Lhaven/render/Pipe$Op; 
SourceFile TreeScale.java  #  	 $ % & 
  haven/res/lib/tree/TreeScale haven/GAttrib ' haven/Gob$SetupMod SetupMod ( haven/render/Pipe$Op (Lhaven/Gob;)V haven/res/lib/tree/Tree mkscale (F)Lhaven/render/Location; 	haven/Gob haven/render/Pipe 
tree.cjava !        	    
            7     *+� *$� *$� � �               
 !  "             *� �           %      )       ! 	    	code   haven.res.lib.tree.Tree ����   4� � �
  �
  �
 x � �
  � �
 � �  � � � � �	  �	  � �
 ! �
  �	  �
 � �
  �  � �
 � � �	  �	  �	 x � � � �
  �
 x �	  � �
 ! �  � 	  � � �  �	 E �	 � �
 � �	 E �	 � �
 � �	 � �
 � � �	 � �
 0 �
 0 �	 � �
 0 �	 � �
 0 � �@	!�TD-@       
 0 �@P       �
 8 �
 8 
 @
 
 x
 x
 y	 x	 x	 x	

 x
 L
 E
 P
 R
 x	 x	 x	 x
 v	 x j 	 x
 0 �
 0?�������?�      
 8?�ffffff	 x 
 !" j#	$%&'(
*+	,-.	,/
*0
 q1
*23
 v �45 fscale F parts Node InnerClasses  [[Lhaven/render/RenderTree$Node; stage I sel leaves Lhaven/res/lib/tree/LeafSpec; slots Ljava/util/Collection; 	Signature Slot 6Ljava/util/Collection<Lhaven/render/RenderTree$Slot;>; deffac Lhaven/res/lib/tree/Factory; lrand Ljava/util/Random; lrate D mkscale (FFF)Lhaven/render/Location; Code LineNumberTable (F)Lhaven/render/Location; lsparts )(Lhaven/Resource;I)Ljava/util/Collection; StackMapTable �6 � j(Lhaven/Resource;I)Ljava/util/Collection<Lhaven/Pair<Ljava/lang/Integer;Lhaven/render/RenderTree$Node;>;>; mkparts 4(Lhaven/Resource;II)[[Lhaven/render/RenderTree$Node;7 �48  randoom (Lhaven/Gob;)Ljava/util/Random; rndrot +(Ljava/util/Random;)Lhaven/render/Location;9 Owner -(Lhaven/Sprite$Owner;)Lhaven/render/Location; <init> *(Lhaven/Sprite$Owner;Lhaven/Resource;FII)V9 mksprite N(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)Lhaven/res/lib/tree/Tree; added !(Lhaven/render/RenderTree$Slot;)V removed tick (D)Z � <clinit> ()V 
SourceFile 	Tree.java haven/render/Location haven/Matrix4f �: �; � � java/util/ArrayList �<= haven/FastMesh$MeshRes MeshRes8>?@A6BCDEF �GH 
haven/PairIJKLMNOPU �VWX haven/Material$Res ResY\] haven/RenderLink$Res^_`abc java/util/Collection � � � �de java/lang/Integerfghe [Lhaven/render/RenderTree$Node;i haven/render/RenderTree$Nodejklmnompqrstuvwxz{|}~� java/util/RandomF� ����� ���� ��� java/lang/Math�� haven/Coord3f���� ���� 	haven/Gob � � � � �� � � � � z { haven/res/lib/tree/TreeRotation � � ���� haven/res/lib/svaj/GobSvaj �� haven/res/lib/tree/TreeScale �� � � |  � � � �� � � �W��X � ��� haven/Loading�� � ��C��� haven/render/RenderTree$Slot������K� haven/render/Location$Chain Chain�K��G� haven/res/lib/tree/StdLeaf�N�� ���� haven/res/lib/tree/Factory haven/res/lib/tree/Tree haven/Sprite java/util/Iterator [Ljava/util/Collection; haven/Resource haven/Sprite$Owner (FFFFFFFFFFFFFFFF)V (Lhaven/Matrix4f;)V (I)V haven/FastMesh layers )(Ljava/lang/Class;)Ljava/util/Collection; iterator ()Ljava/util/Iterator; hasNext ()Z next ()Ljava/lang/Object; id mat Lhaven/Material$Res; valueOf (I)Ljava/lang/Integer; get ()Lhaven/Material; m Lhaven/FastMesh; haven/Material apply� Op� Wrapping ?(Lhaven/render/RenderTree$Node;)Lhaven/render/Pipe$Op$Wrapping; '(Ljava/lang/Object;Ljava/lang/Object;)V add (Ljava/lang/Object;)Z layer� IDLayer =(Ljava/lang/Class;Ljava/lang/Object;)Lhaven/Resource$IDLayer; haven/RenderLink l Lhaven/RenderLink; owner Lhaven/Sprite$Owner; make 4(Lhaven/Sprite$Owner;)Lhaven/render/RenderTree$Node; a Ljava/lang/Object; intValue ()I b haven/render/RenderTree toArray (([Ljava/lang/Object;)[Ljava/lang/Object; rc Lhaven/Coord2d; haven/MCache tilesz haven/Coord2d floor (Lhaven/Coord2d;)Lhaven/Coord; glob Lhaven/Glob; 
haven/Glob map Lhaven/MCache; getgridt Grid "(Lhaven/Coord;)Lhaven/MCache$Grid; haven/MCache$Grid ul Lhaven/Coord; haven/Coord sub (Lhaven/Coord;)Lhaven/Coord; J (J)V nextLong ()J x setSeed y 
nextDouble ()D nextGaussian sin (D)D cos (FFF)V rot )(Lhaven/Coord3f;F)Lhaven/render/Location; '(Lhaven/Sprite$Owner;Lhaven/Resource;)V %(Lhaven/Gob;Lhaven/render/Location;)V setattr (Lhaven/GAttrib;)V (Lhaven/Gob;)V (Lhaven/Gob;F)V create >(Lhaven/render/RenderTree$Node;)Lhaven/render/RenderTree$Slot; remove nextInt (I)I pow (DD)D isEmpty haven/Utils el ((Ljava/lang/Iterable;)Ljava/lang/Object; state ()Lhaven/render/GroupPipe; haven/render/Homo3D loc� Lhaven/render/State$Slot; haven/render/GroupPipe /(Lhaven/render/State$Slot;)Lhaven/render/State; "haven/res/lib/leaves/FallingLeaves 2(Lhaven/Glob;)Lhaven/res/lib/leaves/FallingLeaves; haven/res/lib/tree/LeafSpec [Lhaven/Material; mesh 	onevertex >(Lhaven/render/Location$Chain;Lhaven/FastMesh;)Lhaven/Coord3f; F(Lhaven/res/lib/leaves/FallingLeaves;Lhaven/Coord3f;Lhaven/Material;)V addleaf� Leaf ,(Lhaven/res/lib/leaves/FallingLeaves$Leaf;)V� haven/render/Pipe$Op haven/render/Pipe$Op$Wrapping haven/Resource$IDLayer� haven/render/State$Slot 'haven/res/lib/leaves/FallingLeaves$Leaf haven/render/Pipe haven/render/State 
tree.cjava ! x y   	  z {    |     � �    � �    � �    � �  �    �  � �    � �    � �    	 � �  �   7     � Y� Y"#$� � �    �       > 	 � �  �        """� �    �       E  � �  �  �  	  	� Y� N+� 	� 
 :�  � ��  � :� � � � 6 �~z6� � 1� � b-� Y� � � � � � �  W� <+h`� � � :� #-� Y� � � � � �  W��]+� 	� 
 :�  � 6�  � :-� Y� � � *� �  � �  W���-�    �   ( 	�  � �� ! �D� -� 8� �  �� < �   >    I 
 J - K @ L J M S N [ O � Q � R � S � U � V � W X Y �    �  � �  �  �    � :6�� �� Y� S����xd6*+� � 
 :�  � ��  � :�  � !� "~x~� ����  � !� " ~z6� � x~� ����  � !� "#~z~6	6

�� (	� 	
x~� 
2� $�  W�
��֧�c�� %:6�� 2� &� ' � %S�����    �   G � 	 �� �  �� - �� (� �   � � � �  � � 
 �� # �   R    ^  _ # ` , a O b d c g d { e � f � g � h � i � j � h � k � l � m � n m o 	 � �  �   z     J*� (� )� *L*� +� ,+� -M+,� .� /L� 0Y,� 1� 2N--� 3+� 4��� 5--� 3+� 6��� 5-�    �       s  t  u   v , w : x H y 	 � �  �   Z     6*� 7 9k ;kH*� = 9k >oJ� @Y'� A�'� B�� C:)�� D�    �       }  ~   . � 	 � �  �   =     *� E� *� E� F� G��    �     �       �  �  �  � �  �   �     x*+,� H*� I*� Y� � J*%� K+� E� E+� E:� LY� M� N� O� PY� Q� O*� K�� � RY*� K� S� O**,� T� U*� V�    �    � d  � � �   �   6    �  :  ;  �  � " � ( � ; � I � R � d � q � w � 	 � �  �   "     
� W*+,� X�    �       �  � �  �   r     7*� U*� Y2M,�>6� ,2:+� Z W����*� J+�  W�    �    �  %�  �       �  � % � + � 6 �  � �  �   (     *� J+� [ W�    �   
    �  �  � �  �  �     �*� I� �*� \� Y*� 0Y� ]� \*� \� ^� *� I� �*� \N*� � E� *� � E� FN� :� �* `-� 7 b� d ekc� g*� K� b�� �*� J� h � v*� \� 7*� g'� d�� c*� J� i� j� k � l� m � nN*� � E� +� o:*� I� p*� \*� I� p�� ^2:� qY-*� I� r� s� t� u� N�  ; F I _ r � � _  �   ! ,�   � �  �� � ~B �  �   Z    �  �  �  � $ � ) � , � 1 � ; � F � I � K � N � d � p � r � � � � � � � � � � � � �  � �  �   #      � vY� w� W�    �       �  �   � ~   j  & � }	 j � �	 � y �	  � � 	  � � 	  � � 	 n ) 	Q�R	SQT 	Z �[	 � �y �� � 	�*�code >  haven.res.lib.tree.LeafSpec ����   4 
     mesh Lhaven/FastMesh; mat [Lhaven/Material; <init> ()V Code LineNumberTable 
SourceFile LeafSpec.java  	 haven/res/lib/tree/LeafSpec java/lang/Object 
tree.cjava !                   	  
        *� �           �      code 5  haven.res.lib.tree.Factory ����   4 �
 5 U	 4 V
 4 U W X
  Y 7
  Z [
 	 \	  ] ^
  \
 _ `
 4 a
 b c
 b dB�   e
  f	  V
 g h i j
  U l
  n o p q r q s	  t	 ( u	  v	  w x y
 # z {
 & U |
 ( ~ o  o � � � o � �	  �
 5 �
  �
 4 � � � � leaves Lhaven/res/lib/tree/LeafSpec; <init> ()V Code LineNumberTable &(Lhaven/Resource;[Ljava/lang/Object;)V StackMapTable � i � X create � Owner InnerClasses N(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)Lhaven/res/lib/tree/Tree; e 
dropleaves !(Lhaven/Resource;ILhaven/Indir;)V j � � 	Signature 3(Lhaven/Resource;ILhaven/Indir<Lhaven/Resource;>;)V (ILhaven/Indir;)V #(ILhaven/Indir<Lhaven/Resource;>;)V C(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)Lhaven/Sprite; 
SourceFile Factory.java 9 : 7 8 [Ljava/lang/Object; java/lang/String � � � � java/lang/Number � � � � java/lang/Integer � � � I J � � � � � haven/res/lib/tree/Tree 9 � � � � haven/Resource haven/res/lib/tree/LeafSpec � haven/FastMesh$MeshRes MeshRes � � � � � � � � � � � � � � � � � � java/lang/RuntimeException No leaf-dropping mesh 9 � java/util/ArrayList haven/Material$Res Res � � � � � � No leaf materials haven/Material � � [Lhaven/Material; � � � � � � C G haven/res/lib/tree/Factory java/lang/Object � haven/Sprite$Factory Factory haven/Sprite$Owner java/util/Iterator java/util/Collection hashCode ()I equals (Ljava/lang/Object;)Z intValue pool Pool Lhaven/Resource$Pool; haven/Resource$Pool load � Named +(Ljava/lang/String;I)Lhaven/Resource$Named; haven/Message eom ()Z uint8 *(Lhaven/Sprite$Owner;Lhaven/Resource;FII)V haven/Loading waitfor !(Lhaven/Indir;)Ljava/lang/Object; haven/FastMesh layers )(Ljava/lang/Class;)Ljava/util/Collection; iterator ()Ljava/util/Iterator; hasNext next ()Ljava/lang/Object; mat Lhaven/Material$Res; id I m Lhaven/FastMesh; mesh (Ljava/lang/String;)V get ()Lhaven/Material; add isEmpty toArray (([Ljava/lang/Object;)[Ljava/lang/Object; getClass ()Ljava/lang/Class; classres #(Ljava/lang/Class;)Lhaven/Resource; haven/Sprite haven/Resource$Named 
tree.cjava ! 4 5  6   7 8     9 :  ;   *     
*� *� �    <       �  � 	 �  9 =  ;    
   �*� ,N-�66� �-2:� � :2� :6	� �         ���   � � 6		�   8          *+2� 	� 
+� 2� 2� � � � ���{�    >   P �   ? @    � : 
 ? @   A  B  � &  ? @    �  <       �  �  � $ � h � � � � �  C G  ;   �     i66-� � '-� 6 �~�  �~zd6~x6-� � � -� �n8� Y+,� :� *� � �    >    � (� 
G� ! H <   .    �  �  �  �  � ( � 1 � F � W � ] � f �  I J  ;  E  	   �-� � :� Y� :+� �  :�  � (�  � :� �  � � !� "���� "� � #Y$� %�� &Y� ':(� �  :�  � �  � (:� )� * W���� + � � #Y,� %�� -� . � /� 0*� �    >     �  @ K L+� �  M L� % <   B    � 	 �  � 5 � A � K  N V ` i � � � � �	 �
 N    O  I P  ;   *     **� 1� 2,� �    <   
     N    QA C R  ;         *+,-� 3�    <       �  S    � F   2  D � E	  k m 	 ( - } 	 6 � �	 _  � 	 �  �	code �  haven.res.lib.tree.StdLeaf ����   4 
  
  	     m Lhaven/Material; <init> F(Lhaven/res/lib/leaves/FallingLeaves;Lhaven/Coord3f;Lhaven/Material;)V Code LineNumberTable mat ()Lhaven/Material; 
SourceFile StdLeaf.java        haven/res/lib/tree/StdLeaf  'haven/res/lib/leaves/FallingLeaves$Leaf Leaf InnerClasses java/lang/Object getClass ()Ljava/lang/Class; 6(Lhaven/res/lib/leaves/FallingLeaves;Lhaven/Coord3f;)V "haven/res/lib/leaves/FallingLeaves 
tree.cjava !              	  
   1     *+Y� W,� *-� �           �  �  �     
        *� �           �          
    codeentry '   lib/globfx  lib/leaves  lib/svaj   