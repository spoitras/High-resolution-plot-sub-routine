   � !TO "BUILD/PLOT-BAS.PRG" 9
 � **** PLOT.BAS **** x BASE � 8192 : � 53272,�(53272) � 8:� PUT HIRES MAP AT 8192 � � 53265,�(53265) � 32 : � ENTER BITMAP MODE �( � I � BASE � BASE � 7999 : � I,0 : � : � CLEAR SCREEN 	2 � I � 1024 � 2023 : � I,16 : � : � SET COLORS 	< � 200 ;	P � **** PLOT ROUTINE **** P	Z CHAR � �(HPSN�8) d	d ROW � �(VPSN�8) x	n LINE � VPSN � 7 �	x BYTE � BASE � ROW � 320 � 8 � CHAR � LINE �	� BIT � 7 � (HPSN � 7) �	� � BYTE,�(BYTE) � (2�BIT) �	� � 
� HPSN�160:VPSN�100:� 80:� ONE DOT IN THE MIDDLE +
� � 210 : � FOREVER   