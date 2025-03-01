Haven Resource 1 src c  Named.java /* Preprocessed source code */
/* $use: ui/obj/buddy */

package haven.res.ui.obj.buddy_n;

import haven.*;
import haven.res.ui.obj.buddy.*;
import java.awt.Color;
import java.awt.image.BufferedImage;

/* >objdelta: Named */
public class Named extends GAttrib implements InfoPart {
    public final Info info;
    public final String nm;
    public final Color col;
    public final boolean auto;

    public Named(Gob gob, String nm, Color col, boolean auto) {
	super(gob);
	this.nm = nm;
	this.col = col;
	this.auto = auto;
	info = Info.add(gob, this);
    }

    public static void parse(Gob gob, Message dat) {
	String nm = dat.string();
	if(nm.length() > 0) {
	    Color col = BuddyWnd.gc[dat.uint8()];
	    int fl = dat.uint8();
	    gob.setattr(new Named(gob, nm, col, (fl & 1) != 0));
	} else {
	    gob.delattr(Named.class);
	}
    }

    public void dispose() {
	super.dispose();
	info.remove(this);
    }

    public void draw(CompImage cmp, RenderContext ctx) {
	cmp.add(Utils.outline2(Text.std.render(nm, col).img, Utils.contrast(col)), Coord.z);
    }

    public boolean auto() {return(auto);}
}
code �  haven.res.ui.obj.buddy_n.Named ����   4 �
  4	  5	  6	  7
 8 9	  :
 ; <
 = >	 ? @
 ; A B
  C
 D E
 D F
  G
 8 H	 I J
 K L	 M N
 O P
 O Q	 R S
 T U V W info Lhaven/res/ui/obj/buddy/Info; nm Ljava/lang/String; col Ljava/awt/Color; auto Z <init> 1(Lhaven/Gob;Ljava/lang/String;Ljava/awt/Color;Z)V Code LineNumberTable parse (Lhaven/Gob;Lhaven/Message;)V StackMapTable X Y Z [ dispose ()V draw )(Lhaven/CompImage;Lhaven/RenderContext;)V ()Z 
SourceFile 
Named.java " \       ! ] ^ _   Y ` a Z b c d e f g c haven/res/ui/obj/buddy_n/Named " # X h i j k - . l m n o r s t v w x y z { | } ~  � � � ^ � haven/GAttrib haven/res/ui/obj/buddy/InfoPart 	haven/Gob haven/Message java/lang/String java/awt/Color (Lhaven/Gob;)V haven/res/ui/obj/buddy/Info add K(Lhaven/Gob;Lhaven/res/ui/obj/buddy/InfoPart;)Lhaven/res/ui/obj/buddy/Info; string ()Ljava/lang/String; length ()I haven/BuddyWnd gc [Ljava/awt/Color; uint8 setattr (Lhaven/GAttrib;)V delattr (Ljava/lang/Class;)V remove $(Lhaven/res/ui/obj/buddy/InfoPart;)V 
haven/Text std Foundry InnerClasses Lhaven/Text$Foundry; haven/Text$Foundry render Line 5(Ljava/lang/String;Ljava/awt/Color;)Lhaven/Text$Line; haven/Text$Line img Ljava/awt/image/BufferedImage; haven/Utils contrast "(Ljava/awt/Color;)Ljava/awt/Color; outline2 N(Ljava/awt/image/BufferedImage;Ljava/awt/Color;)Ljava/awt/image/BufferedImage; haven/Coord z Lhaven/Coord; haven/CompImage >(Ljava/awt/image/BufferedImage;Lhaven/Coord;)Lhaven/CompImage; buddy-n.cjava !                        !     " #  $   K     *+� *,� *-� *� *+*� � �    %          
        	 & '  $   �     ?+� M,� � /� 	+� 
2N+� 
6*� Y*,-~� � � � � 	*� �    (   S � .  ) * + ,  )   ) + ,�    ) * + ,  )   ) + ,�  %   "             5  8   > "  - .  $   -     *� *� *� �    %       %  &  '  / 0  $   @     $+� *� *� � � *� � � � � W�    %   
    * # +    1  $        *� �    %       -  2    � q     K I p 	 M I u 	codeentry <   objdelta haven.res.ui.obj.buddy_n.Named   ui/obj/buddy   