Haven Resource 1 src T	  Teimdeer.java /* Preprocessed source code */
/* $use: ui/croster */

package haven.res.gfx.hud.rosters.teimdeer;

import haven.*;
import haven.res.ui.croster.*;
import java.util.*;

public class Teimdeer extends Entry {
    public int meat, milk;
    public int meatq, milkq, hideq;
    public int seedq;
    public boolean buck, fawn, dead, pregnant, lactate, owned, mine;

    public Teimdeer(long id, String name) {
	super(SIZE, id, name);
    }

    public void draw(GOut g) {
	drawbg(g);
	int i = 0;
	drawcol(g, TeimdeerRoster.cols.get(i), 0, this, namerend, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 0.5, buck,     sex, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 0.5, fawn,     growth, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 0.5, dead,     deadrend, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 0.5, pregnant, pregrend, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 0.5, lactate,  lactrend, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 0.5, (owned ? 1 : 0) | (mine ? 2 : 0), ownrend, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 1, q, quality, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 1, meat, null, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 1, milk, null, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 1, meatq, percent, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 1, milkq, percent, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 1, hideq, percent, i++);
	drawcol(g, TeimdeerRoster.cols.get(i), 1, seedq, null, i++);
	super.draw(g);
    }

    public boolean mousedown(Coord c, int button) {
	if(TeimdeerRoster.cols.get(1).hasx(c.x)) {
	    markall(Teimdeer.class, o -> (o.buck == this.buck));
	    return(true);
	}
	if(TeimdeerRoster.cols.get(2).hasx(c.x)) {
	    markall(Teimdeer.class, o -> (o.fawn == this.fawn));
	    return(true);
	}
	if(TeimdeerRoster.cols.get(3).hasx(c.x)) {
	    markall(Teimdeer.class, o -> (o.dead == this.dead));
	    return(true);
	}
	if(TeimdeerRoster.cols.get(4).hasx(c.x)) {
	    markall(Teimdeer.class, o -> (o.pregnant == this.pregnant));
	    return(true);
	}
	if(TeimdeerRoster.cols.get(5).hasx(c.x)) {
	    markall(Teimdeer.class, o -> (o.lactate == this.lactate));
	    return(true);
	}
	if(TeimdeerRoster.cols.get(6).hasx(c.x)) {
	    markall(Teimdeer.class, o -> ((o.owned == this.owned) && (o.mine == this.mine)));
	    return(true);
	}
	return(super.mousedown(c, button));
    }
}

/* >wdg: TeimdeerRoster */
src ~  TeimdeerRoster.java /* Preprocessed source code */
/* $use: ui/croster */

package haven.res.gfx.hud.rosters.teimdeer;

import haven.*;
import haven.res.ui.croster.*;
import java.util.*;

public class TeimdeerRoster extends CattleRoster<Teimdeer> {
    public static List<Column> cols = initcols(
	new Column<Entry>("Name", Comparator.comparing((Entry e) -> e.name), 200),

	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/sex", 2),      Comparator.comparing((Teimdeer e) -> e.buck).reversed(), 20).runon(),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/growth", 2),   Comparator.comparing((Teimdeer e) -> e.fawn).reversed(), 20).runon(),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/deadp", 3),    Comparator.comparing((Teimdeer e) -> e.dead).reversed(), 20).runon(),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/pregnant", 2), Comparator.comparing((Teimdeer e) -> e.pregnant).reversed(), 20).runon(),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/lactate", 1),  Comparator.comparing((Teimdeer e) -> e.lactate).reversed(), 20).runon(),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/owned", 1),    Comparator.comparing((Teimdeer e) -> ((e.owned ? 1 : 0) | (e.mine ? 2 : 0))).reversed(), 20),

	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/quality", 2), Comparator.comparing((Teimdeer e) -> e.q).reversed()),

	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/meatquantity", 1), Comparator.comparing((Teimdeer e) -> e.meat).reversed()),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/milkquantity", 1), Comparator.comparing((Teimdeer e) -> e.milk).reversed()),

	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/meatquality", 1), Comparator.comparing((Teimdeer e) -> e.meatq).reversed()),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/milkquality", 1), Comparator.comparing((Teimdeer e) -> e.milkq).reversed()),
	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/hidequality", 1), Comparator.comparing((Teimdeer e) -> e.hideq).reversed()),

	new Column<Teimdeer>(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/breedingquality", 1), Comparator.comparing((Teimdeer e) -> e.seedq).reversed())
    );
    protected List<Column> cols() {return(cols);}

    public static CattleRoster mkwidget(UI ui, Object... args) {
	return(new TeimdeerRoster());
    }

    public Teimdeer parse(Object... args) {
	int n = 0;
	long id = ((Number)args[n++]).longValue();
	String name = (String)args[n++];
	Teimdeer ret = new Teimdeer(id, name);
	ret.grp = (Integer)args[n++];
	int fl = (Integer)args[n++];
	ret.buck = (fl & 1) != 0;
	ret.fawn = (fl & 2) != 0;
	ret.dead = (fl & 4) != 0;
	ret.pregnant = (fl & 8) != 0;
	ret.lactate = (fl & 16) != 0;
	ret.owned = (fl & 32) != 0;
	ret.mine = (fl & 64) != 0;
	ret.q = ((Number)args[n++]).doubleValue();
	ret.meat = (Integer)args[n++];
	ret.milk = (Integer)args[n++];
	ret.meatq = (Integer)args[n++];
	ret.milkq = (Integer)args[n++];
	ret.hideq = (Integer)args[n++];
	ret.seedq = (Integer)args[n++];
	return(ret);
    }

    public TypeButton button() {
	return(typebtn(Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/btn-teimdeer", 1),
		       Resource.classres(TeimdeerRoster.class).pool.load("gfx/hud/rosters/btn-teimdeer-d", 1)));
    }
}
code �  haven.res.gfx.hud.rosters.teimdeer.Teimdeer ����   4 �	      +haven/res/gfx/hud/rosters/teimdeer/Teimdeer SIZE Lhaven/Coord;
  	 
   haven/res/ui/croster/Entry <init> #(Lhaven/Coord;JLjava/lang/String;)V
     drawbg (Lhaven/GOut;)V	      1haven/res/gfx/hud/rosters/teimdeer/TeimdeerRoster cols Ljava/util/List;      java/util/List get (I)Ljava/lang/Object;  haven/res/ui/croster/Column	    ! " namerend Ljava/util/function/Function;
  $ % & drawcol ](Lhaven/GOut;Lhaven/res/ui/croster/Column;DLjava/lang/Object;Ljava/util/function/Function;I)V?�      	  * + , buck Z
 . / 0 1 2 java/lang/Boolean valueOf (Z)Ljava/lang/Boolean;	  4 5 " sex	  7 8 , fawn	  : ; " growth	  = > , dead	  @ A " deadrend	  C D , pregnant	  F G " pregrend	  I J , lactate	  L M " lactrend	  O P , owned	  R S , mine
 U V W 1 X java/lang/Integer (I)Ljava/lang/Integer;	  Z [ " ownrend	  ] ^ _ q D
 a b c 1 d java/lang/Double (D)Ljava/lang/Double;	  f g " quality	  i j k meat I	  m n k milk	  p q k meatq	  s t " percent	  v w k milkq	  y z k hideq	  | } k seedq
   �  draw	 � � � � k haven/Coord x
  � � � hasx (I)Z   � � � test M(Lhaven/res/gfx/hud/rosters/teimdeer/Teimdeer;)Ljava/util/function/Predicate;
  � � � markall 2(Ljava/lang/Class;Ljava/util/function/Predicate;)V  �  �  �  �  �
  � � � 	mousedown (Lhaven/Coord;I)Z (JLjava/lang/String;)V Code LineNumberTable StackMapTable � 
haven/GOut lambda$mousedown$5 0(Lhaven/res/gfx/hud/rosters/teimdeer/Teimdeer;)Z lambda$mousedown$4 lambda$mousedown$3 lambda$mousedown$2 lambda$mousedown$1 lambda$mousedown$0 
SourceFile Teimdeer.java BootstrapMethods �
 � � � � � "java/lang/invoke/LambdaMetafactory metafactory �(Ljava/lang/invoke/MethodHandles$Lookup;Ljava/lang/String;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodHandle;Ljava/lang/invoke/MethodType;)Ljava/lang/invoke/CallSite; � (Ljava/lang/Object;)Z �
  � � � � �
  � � � �
  � � � �
  � � � �
  � � � �
  � � � InnerClasses � %java/lang/invoke/MethodHandles$Lookup � java/lang/invoke/MethodHandles Lookup teimdeer.cjava !       j k    n k    q k    w k    z k    } k    + ,    8 ,    > ,    D ,    J ,    P ,    S ,   	   �  �   &     
*� -� �    �   
     	   �   �  �    �*+� =*+� �  � *� �� #*+� �  �  '*� )� -� 3�� #*+� �  �  '*� 6� -� 9�� #*+� �  �  '*� <� -� ?�� #*+� �  �  '*� B� -� E�� #*+� �  �  '*� H� -� K�� #*+� �  �  '*� N� � *� Q� � �� T� Y�� #*+� �  � *� \� `� e�� #*+� �  � *� h� T�� #*+� �  � *� l� T�� #*+� �  � *� o� T� r�� #*+� �  � *� u� T� r�� #*+� �  � *� x� T� r�� #*+� �  � *� {� T�� #*+� ~�    �   f � �   �   � �     �   � � 
   �   � �     �   �  �   J         !  C  e  �  �  �  " @ ^  ~ !� "� #� $� %  � �  �  N     � �  � +� �� �� **� �  � ��� �  � +� �� �� **� �  � ��� �  � +� �� �� **� �  � ��� �  � +� �� �� **� �  � ��� �  � +� �� �� **� �  � ��� �  � +� �� �� **� �  � ��*+� ��    �    $####$ �   N    (  ) " * $ , : - F . H 0 ^ 1 j 2 l 4 � 5 � 6 � 8 � 9 � : � < � = � > � @ � �  �   ?     +� N*� N� +� Q*� Q� � �    �    @ �       = � �  �   4     +� H*� H� � �    �    @ �       9 � �  �   4     +� B*� B� � �    �    @ �       5 � �  �   4     +� <*� <� � �    �    @ �       1 � �  �   4     +� 6*� 6� � �    �    @ �       - � �  �   4     +� )*� )� � �    �    @ �       )  �   >  �  � � � �  � � � �  � � � �  � � � �  � � � �  � � � �    � �   
  � � � code �  haven.res.gfx.hud.rosters.teimdeer.TeimdeerRoster ����   46
      !haven/res/ui/croster/CattleRoster <init> ()V	  	 
   1haven/res/gfx/hud/rosters/teimdeer/TeimdeerRoster cols Ljava/util/List;
    java/lang/Number
     	longValue ()J  java/lang/String  +haven/res/gfx/hud/rosters/teimdeer/Teimdeer
     (JLjava/lang/String;)V  java/lang/Integer
      intValue ()I	  " # $ grp I	  & ' ( buck Z	  * + ( fawn	  - . ( dead	  0 1 ( pregnant	  3 4 ( lactate	  6 7 ( owned	  9 : ( mine
  < = > doubleValue ()D	  @ A B q D	  D E $ meat	  G H $ milk	  J K $ meatq	  M N $ milkq	  P Q $ hideq	  S T $ seedq
 V W X Y Z haven/Resource classres #(Ljava/lang/Class;)Lhaven/Resource;	 V \ ] ^ pool Lhaven/Resource$Pool; ` gfx/hud/rosters/btn-teimdeer
 b c d e f haven/Resource$Pool load +(Ljava/lang/String;I)Lhaven/Resource$Named; h gfx/hud/rosters/btn-teimdeer-d
  j k l typebtn =(Lhaven/Indir;Lhaven/Indir;)Lhaven/res/ui/croster/TypeButton;
  n o p parse B([Ljava/lang/Object;)Lhaven/res/gfx/hud/rosters/teimdeer/Teimdeer;
  r s t valueOf (I)Ljava/lang/Integer;
 v w x s y java/lang/Double (D)Ljava/lang/Double;
 { | } s ~ java/lang/Boolean (Z)Ljava/lang/Boolean;	 � � � � � haven/res/ui/croster/Entry name Ljava/lang/String; � haven/res/ui/croster/Column � Name   � � � apply ()Ljava/util/function/Function; � � � � � java/util/Comparator 	comparing 5(Ljava/util/function/Function;)Ljava/util/Comparator;
 � �  � ,(Ljava/lang/String;Ljava/util/Comparator;I)V � gfx/hud/rosters/sex  � � � � � reversed ()Ljava/util/Comparator;
 � �  � '(Lhaven/Indir;Ljava/util/Comparator;I)V
 � � � � runon ()Lhaven/res/ui/croster/Column; � gfx/hud/rosters/growth  � � gfx/hud/rosters/deadp  � � gfx/hud/rosters/pregnant  � � gfx/hud/rosters/lactate  � � gfx/hud/rosters/owned  � � gfx/hud/rosters/quality  �
 � �  � &(Lhaven/Indir;Ljava/util/Comparator;)V � gfx/hud/rosters/meatquantity  � � gfx/hud/rosters/milkquantity 	 � � gfx/hud/rosters/meatquality 
 � � gfx/hud/rosters/milkquality  � � gfx/hud/rosters/hidequality  � � gfx/hud/rosters/breedingquality  �
  � � � initcols 0([Lhaven/res/ui/croster/Column;)Ljava/util/List; 	Signature /Ljava/util/List<Lhaven/res/ui/croster/Column;>; Code LineNumberTable ()Ljava/util/List; 1()Ljava/util/List<Lhaven/res/ui/croster/Column;>; mkwidget B(Lhaven/UI;[Ljava/lang/Object;)Lhaven/res/ui/croster/CattleRoster; StackMapTable � [Ljava/lang/Object; button #()Lhaven/res/ui/croster/TypeButton; 1([Ljava/lang/Object;)Lhaven/res/ui/croster/Entry; lambda$static$13 B(Lhaven/res/gfx/hud/rosters/teimdeer/Teimdeer;)Ljava/lang/Integer; lambda$static$12 lambda$static$11 lambda$static$10 lambda$static$9 lambda$static$8 lambda$static$7 A(Lhaven/res/gfx/hud/rosters/teimdeer/Teimdeer;)Ljava/lang/Double; lambda$static$6 lambda$static$5 B(Lhaven/res/gfx/hud/rosters/teimdeer/Teimdeer;)Ljava/lang/Boolean; lambda$static$4 lambda$static$3 lambda$static$2 lambda$static$1 lambda$static$0 0(Lhaven/res/ui/croster/Entry;)Ljava/lang/String; <clinit> RLhaven/res/ui/croster/CattleRoster<Lhaven/res/gfx/hud/rosters/teimdeer/Teimdeer;>; 
SourceFile TeimdeerRoster.java BootstrapMethods �
 � � � � � "java/lang/invoke/LambdaMetafactory metafactory �(Ljava/lang/invoke/MethodHandles$Lookup;Ljava/lang/String;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodHandle;Ljava/lang/invoke/MethodType;)Ljava/lang/invoke/CallSite; � &(Ljava/lang/Object;)Ljava/lang/Object; �
  � � � �
  � � �
  � �	
 
 � �
  � �
  � �
  � � �
  � � �
  � �
  � � 
 ! � �#
 $ � �&
 ' � �)
 * � � InnerClasses Pool. haven/Resource$Named Named1 %java/lang/invoke/MethodHandles$Lookup3 java/lang/invoke/MethodHandles Lookup teimdeer.cjava !      	    �    �      �        *� �    �       E   �  �        � �    �       [ �    � � � �  �         � Y� �    �       ^ � o p  �  �    :=+�2� � B+�2� :� Y!� :+�2� � � !+�2� � 6~� � � %~� � � )~� � � ,~� � � /~� � � 2 ~� � � 5@~� � � 8+�2� � ;� ?+�2� � � C+�2� � � F+�2� � � I+�2� � � L+�2� � � O+�2� � � R�    �   � � R   �    �     �    O �     �    O �     �    P �     �    P �     �    P �     �    P �     �     �   V    b  c  d  e & f 7 g E h V i g j x k � l � m � n � o � p � q � r s t& u7 v  � �  �   @      � U� [_� a� U� [g� a� i�    �       z  {  zA o �  �        *+� m�    �       E
 � �  �         *� R� q�    �       Y
 � �  �         *� O� q�    �       W
 � �  �         *� L� q�    �       V
 � �  �         *� I� q�    �       U
 � �  �         *� F� q�    �       S
 � �  �         *� C� q�    �       R
 � �  �         *� ?� u�    �       P
 � �  �   N     *� 5� � *� 8� � �� q�    �    @J�      �       N
 � �  �         *� 2� z�    �       M
 � �  �         *� /� z�    �       L
 � �  �         *� ,� z�    �       K
 � �  �         *� )� z�    �       J
 � �  �         *� %� z�    �       I
 � �  �        *� �    �       G  �   �  {     '� �Y� �Y�� �  � � ȷ �SY� �Y� U� [�� a� �  � �� � � �� �SY� �Y� U� [�� a� �  � �� � � �� �SY� �Y� U� [�� a� �  � �� � � �� �SY� �Y� U� [�� a� �  � �� � � �� �SY� �Y� U� [�� a� �  � �� � � �� �SY� �Y� U� [�� a� �  � �� � � �SY� �Y� U� [�� a� �  � �� � � �SY� �Y� U� [�� a� �  � �� � � �SY	� �Y� U� [�� a� �  � �� � � �SY
� �Y� U� [�� a� �  � �� � � �SY� �Y� U� [�� a� �  � �� � � �SY� �Y� U� [�� a� �  � �� � � �SY� �Y� U� [�� a� �  � �� � � �S� ˳ �    �   B    F  G $ I N J x K � L � M � N PE Rk S� U� V� W Y  F  �   �  �  � �  �  � �  � �  � �  � �  � �  � �  � �  � �  � �  � �  �" �  �% �  �( �   5 �    �+     b V, 	- V/	024 codeentry H   wdg haven.res.gfx.hud.rosters.teimdeer.TeimdeerRoster   ui/croster J  