FasdUAS 1.101.10   ��   ��    k             l     ��������  ��  ��        l     �� 	 
��   	 from [Setting Other Applications' Keyboard Shortcuts using NSUserDefaults - Defaults Not Updating - AppleScript - Late Night Software Ltd.](https://forum.latenightsw.com/t/setting-other-applications-keyboard-shortcuts-using-nsuserdefaults-defaults-not-updating/3537/6)    
 �     f r o m   [ S e t t i n g   O t h e r   A p p l i c a t i o n s '   K e y b o a r d   S h o r t c u t s   u s i n g   N S U s e r D e f a u l t s   -   D e f a u l t s   N o t   U p d a t i n g   -   A p p l e S c r i p t   -   L a t e   N i g h t   S o f t w a r e   L t d . ] ( h t t p s : / / f o r u m . l a t e n i g h t s w . c o m / t / s e t t i n g - o t h e r - a p p l i c a t i o n s - k e y b o a r d - s h o r t c u t s - u s i n g - n s u s e r d e f a u l t s - d e f a u l t s - n o t - u p d a t i n g / 3 5 3 7 / 6 )      l     ��������  ��  ��        l      ��  ��      Public Release 1.0      �   (   P u b l i c   R e l e a s e   1 . 0        l     ��������  ��  ��        x     
�� ����    2   ��
�� 
osax��        x   
 �� ����    4    �� 
�� 
frmk  m       �    F o u n d a t i o n��        l     ��������  ��  ��       !   l     ��������  ��  ��   !  " # " l     �� $ %��   $  - HANDLERS ---    % � & &  -   H A N D L E R S   - - - #  ' ( ' l     �� ) *��   ) &   Getting a user defaults object.    * � + + @   G e t t i n g   a   u s e r   d e f a u l t s   o b j e c t . (  , - , i    . / . I      �� 0���� "0 getuserdefaults getUserDefaults 0  1�� 1 o      ���� 
0 domain  ��  ��   / k      2 2  3 4 3 l     �� 5 6��   5 ` Z Return a NSUserDefaults object for domain, which may be a bundle ID or path-style domain.    6 � 7 7 �   R e t u r n   a   N S U s e r D e f a u l t s   o b j e c t   f o r   d o m a i n ,   w h i c h   m a y   b e   a   b u n d l e   I D   o r   p a t h - s t y l e   d o m a i n . 4  8 9 8 Z     : ;���� : =     < = < o     ���� 
0 domain   = m     > > � ? ?  N S G l o b a l D o m a i n ; r    	 @ A @ m     B B � C C  . N S G l o b a l D o m a i n A o      ���� 
0 domain  ��  ��   9  D�� D L     E E n    F G F I    �� H���� (0 initwithsuitename_ initWithSuiteName_ H  I�� I o    ���� 
0 domain  ��  ��   G n    J K J I    �������� 	0 alloc  ��  ��   K n    L M L o    ����  0 nsuserdefaults NSUserDefaults M m    ��
�� misccura��   -  N O N l     ��������  ��  ��   O  P Q P l     ��������  ��  ��   Q  R S R l     �� T U��   T ' ! Getting preference domain paths.    U � V V B   G e t t i n g   p r e f e r e n c e   d o m a i n   p a t h s . S  W X W i    Y Z Y I      �� [���� 20 applicationhascontainer applicationHasContainer [  \�� \ o      ���� 0 	bundle_id  ��  ��   Z k      ] ]  ^ _ ^ l     �� ` a��   ` H B Return true if a container exists for bundle_id, false otherwise.    a � b b �   R e t u r n   t r u e   i f   a   c o n t a i n e r   e x i s t s   f o r   b u n d l e _ i d ,   f a l s e   o t h e r w i s e . _  c�� c L      d d n     e f e I    �� g���� 0 
fileexists 
fileExists g  h�� h b     i j i b     k l k b    
 m n m n     o p o 1    ��
�� 
psxp p l    q���� q I   �� r��
�� .earsffdralis        afdr r m    ��
�� afdrcusr��  ��  ��   n m    	 s s � t t & L i b r a r y / C o n t a i n e r s / l o   
 ���� 0 	bundle_id   j m     u u � v v  /��  ��   f  f     ��   X  w x w l     ��������  ��  ��   x  y z y i   " { | { I      �� }���� "0 getlegacydomain getLegacyDomain }  ~�� ~ o      ���� 0 	bundle_id  ��  ��   | k         � � � l     �� � ���   � � | Return the standard preferences domain for bundle_id (without the .plist extension) starting with "~/Library/Preferences/".    � � � � �   R e t u r n   t h e   s t a n d a r d   p r e f e r e n c e s   d o m a i n   f o r   b u n d l e _ i d   ( w i t h o u t   t h e   . p l i s t   e x t e n s i o n )   s t a r t i n g   w i t h   " ~ / L i b r a r y / P r e f e r e n c e s / " . �  � � � Z     � ����� � =     � � � o     ���� 0 	bundle_id   � m     � � � � �  N S G l o b a l D o m a i n � r    	 � � � m     � � � � � $ . G l o b a l P r e f e r e n c e s � o      ���� 0 	bundle_id  ��  ��   �  ��� � L     � � b     � � � b     � � � n     � � � 1    ��
�� 
psxp � l    ����� � I   �� ���
�� .earsffdralis        afdr � m    ��
�� afdrcusr��  ��  ��   � m     � � � � � ( L i b r a r y / P r e f e r e n c e s / � o    ���� 0 	bundle_id  ��   z  � � � l     ��������  ��  ��   �  � � � i  # & � � � I      �� ����� (0 getsandboxeddomain getSandboxedDomain �  ��� � o      ���� 0 	bundle_id  ��  ��   � k      � �  � � � l     �� � ���   � � ~ Return the containerized preferences domain for bundle_id (without the .plist extension) for use with sandboxed applications.    � � � � �   R e t u r n   t h e   c o n t a i n e r i z e d   p r e f e r e n c e s   d o m a i n   f o r   b u n d l e _ i d   ( w i t h o u t   t h e   . p l i s t   e x t e n s i o n )   f o r   u s e   w i t h   s a n d b o x e d   a p p l i c a t i o n s . �  ��� � L      � � b      � � � b      � � � b      � � � b     	 � � � n      � � � 1    ��
�� 
psxp � l     ����� � I    �� ���
�� .earsffdralis        afdr � m     ��
�� afdrcusr��  ��  ��   � m     � � � � � & L i b r a r y / C o n t a i n e r s / � o   	 
���� 0 	bundle_id   � m     � � � � � 4 / D a t a / L i b r a r y / P r e f e r e n c e s / � o    ���� 0 	bundle_id  ��   �  � � � l     ��������  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � m g Controlling whether applications should appear in the System Preferences "Application Shortcuts" list.    � � � � �   C o n t r o l l i n g   w h e t h e r   a p p l i c a t i o n s   s h o u l d   a p p e a r   i n   t h e   S y s t e m   P r e f e r e n c e s   " A p p l i c a t i o n   S h o r t c u t s "   l i s t . �  � � � i  ' * � � � I      �������� T0 (getguicustomkeyboardshortcutapplications (getGUICustomKeyboardShortcutApplications��  ��   � k      � �  � � � l     �� � ���   � w q Return the ordered list of applications appearing in the custom keyboard shortcut section of System Preferences.    � � � � �   R e t u r n   t h e   o r d e r e d   l i s t   o f   a p p l i c a t i o n s   a p p e a r i n g   i n   t h e   c u s t o m   k e y b o a r d   s h o r t c u t   s e c t i o n   o f   S y s t e m   P r e f e r e n c e s . �  � � � r      � � � n     � � � I    �� ����� "0 getuserdefaults getUserDefaults �  ��� � m     � � � � � 2 c o m . a p p l e . u n i v e r s a l a c c e s s��  ��   �  f      � o      ���� 0 gui_defaults   �  ��� � L   	  � � c   	  � � � l  	  ����� � n  	  � � � I   
 �� ����� (0 stringarrayforkey_ stringArrayForKey_ �  ��� � m   
  � � � � � 2 c o m . a p p l e . c u s t o m m e n u . a p p s��  ��   � o   	 
���� 0 gui_defaults  ��  ��   � m    ��
�� 
list��   �  � � � l     ��~�}�  �~  �}   �  � � � i  + . � � � I      �| ��{�| T0 (setguicustomkeyboardshortcutapplications (setGUICustomKeyboardShortcutApplications �  ��z � o      �y�y 0 
bundle_ids  �z  �{   � k      � �  � � � l     �x � ��x   � t n Set the ordered list of applications appearing in the custom keyboard shortcut section of System Preferences.    � � � � �   S e t   t h e   o r d e r e d   l i s t   o f   a p p l i c a t i o n s   a p p e a r i n g   i n   t h e   c u s t o m   k e y b o a r d   s h o r t c u t   s e c t i o n   o f   S y s t e m   P r e f e r e n c e s . �  � � � r      � � � n     � � � I    �w ��v�w "0 getuserdefaults getUserDefaults �  ��u � m     � � � � � 2 c o m . a p p l e . u n i v e r s a l a c c e s s�u  �v   �  f      � o      �t�t 0 gui_defaults   �  ��s � n  	  � � � I   
 �r �q�r &0 setobject_forkey_ setObject_forKey_   l  
 �p�o n  
  I    �n�m�n  0 getuniqueitems getUniqueItems �l o    �k�k 0 
bundle_ids  �l  �m    f   
 �p  �o   �j m    		 �

 2 c o m . a p p l e . c u s t o m m e n u . a p p s�j  �q   � o   	 
�i�i 0 gui_defaults  �s   �  l     �h�g�f�h  �g  �f    i  / 2 I      �e�d�e T0 (hasguicustomkeyboardshortcutapplications (hasGUICustomKeyboardShortcutApplications �c o      �b�b 0 	bundle_id  �c  �d   k     
  l     �a�a   y s Return whether the application id bundle_id appears in the custom keyboard shortcut section of System Preferences.    � �   R e t u r n   w h e t h e r   t h e   a p p l i c a t i o n   i d   b u n d l e _ i d   a p p e a r s   i n   t h e   c u s t o m   k e y b o a r d   s h o r t c u t   s e c t i o n   o f   S y s t e m   P r e f e r e n c e s . �` L     
 E    	 n     I    �_�^�]�_ T0 (getguicustomkeyboardshortcutapplications (getGUICustomKeyboardShortcutApplications�^  �]    f      J      �\  o    �[�[ 0 	bundle_id  �\  �`   !"! l     �Z�Y�X�Z  �Y  �X  " #$# i  3 6%&% I      �W'�V�W R0 'addguicustomkeyboardshortcutapplication 'addGUICustomKeyboardShortcutApplication' (�U( o      �T�T 0 	bundle_id  �U  �V  & k     ,)) *+* l     �S,-�S  , � � Add the application id bundle_id to the custom keyboard shortcut section of System Preferences if it is not already included therein.   - �..   A d d   t h e   a p p l i c a t i o n   i d   b u n d l e _ i d   t o   t h e   c u s t o m   k e y b o a r d   s h o r t c u t   s e c t i o n   o f   S y s t e m   P r e f e r e n c e s   i f   i t   i s   n o t   a l r e a d y   i n c l u d e d   t h e r e i n .+ /0/ r     121 n    343 I    �R5�Q�R "0 getuserdefaults getUserDefaults5 6�P6 m    77 �88 2 c o m . a p p l e . u n i v e r s a l a c c e s s�P  �Q  4  f     2 o      �O�O 0 gui_defaults  0 9:9 r   	 ;<; c   	 =>= l  	 ?�N�M? n  	 @A@ I   
 �LB�K�L (0 stringarrayforkey_ stringArrayForKey_B C�JC m   
 DD �EE 2 c o m . a p p l e . c u s t o m m e n u . a p p s�J  �K  A o   	 
�I�I 0 gui_defaults  �N  �M  > m    �H
�H 
list< o      �G�G 0 gui_bundle_ids  : F�FF Z   ,GH�E�DG H    II E   JKJ o    �C�C 0 gui_bundle_ids  K J    LL M�BM o    �A�A 0 	bundle_id  �B  H n   (NON I    (�@P�?�@ &0 setobject_forkey_ setObject_forKey_P QRQ l   #S�>�=S b    #TUT o    �<�< 0 gui_bundle_ids  U J    "VV W�;W o     �:�: 0 	bundle_id  �;  �>  �=  R X�9X m   # $YY �ZZ 2 c o m . a p p l e . c u s t o m m e n u . a p p s�9  �?  O o    �8�8 0 gui_defaults  �E  �D  �F  $ [\[ l     �7�6�5�7  �6  �5  \ ]^] i  7 :_`_ I      �4a�3�4 X0 *removeguicustomkeyboardshortcutapplication *removeGUICustomKeyboardShortcutApplicationa b�2b o      �1�1 0 	bundle_id  �2  �3  ` k     ?cc ded l     �0fg�0  f � | Remove the application id bundle_id from the custom keyboard shortcut section of System Preferences if it is found therein.   g �hh �   R e m o v e   t h e   a p p l i c a t i o n   i d   b u n d l e _ i d   f r o m   t h e   c u s t o m   k e y b o a r d   s h o r t c u t   s e c t i o n   o f   S y s t e m   P r e f e r e n c e s   i f   i t   i s   f o u n d   t h e r e i n .e iji r     klk n    mnm I    �/o�.�/ "0 getuserdefaults getUserDefaultso p�-p m    qq �rr 2 c o m . a p p l e . u n i v e r s a l a c c e s s�-  �.  n  f     l o      �,�, 0 gui_defaults  j sts r   	 uvu c   	 wxw l  	 y�+�*y n  	 z{z I   
 �)|�(�) (0 stringarrayforkey_ stringArrayForKey_| }�'} m   
 ~~ � 2 c o m . a p p l e . c u s t o m m e n u . a p p s�'  �(  { o   	 
�&�& 0 gui_defaults  �+  �*  x m    �%
�% 
listv o      �$�$ 0 gui_bundle_ids  t ��#� Z    ?���"�!� E   ��� o    � �  0 gui_bundle_ids  � J    �� ��� o    �� 0 	bundle_id  �  � Z    ;����� =   !��� n    ��� 1    �
� 
leng� o    �� 0 gui_bundle_ids  � m     �� � l  $ +���� n  $ +��� I   % +���� &0 setobject_forkey_ setObject_forKey_� ��� l  % &���� m   % &�
� 
msng�  �  � ��� m   & '�� ��� 2 c o m . a p p l e . c u s t o m m e n u . a p p s�  �  � o   $ %�� 0 gui_defaults  � "  This is the last bundle ID.   � ��� 8   T h i s   i s   t h e   l a s t   b u n d l e   I D .�  � l  . ;���� n  . ;��� I   / ;���� &0 setobject_forkey_ setObject_forKey_� ��� l  / 6���� n  / 6��� I   0 6���� 00 makelistbyremovingitem makeListByRemovingItem� ��� o   0 1�� 0 gui_bundle_ids  � ��� o   1 2�
�
 0 	bundle_id  �  �  �  f   / 0�  �  � ��	� m   6 7�� ��� 2 c o m . a p p l e . c u s t o m m e n u . a p p s�	  �  � o   . /�� 0 gui_defaults  � $  Other bundle IDs still exist.   � ��� <   O t h e r   b u n d l e   I D s   s t i l l   e x i s t .�"  �!  �#  ^ ��� l     ����  �  �  � ��� l     ����  �  �  � ��� l     ����  � . ( Manipulating custom keyboard shortcuts.   � ��� P   M a n i p u l a t i n g   c u s t o m   k e y b o a r d   s h o r t c u t s .� ��� i  ; >��� I      � ����  J0 #getcustomkeyboardshortcutdictionary #getCustomKeyboardShortcutDictionary� ���� o      ���� 0 	bundle_id  ��  ��  � k     q�� ��� l     ������  � k e Return an NSDictionary representation of the custom keyboard shortcuts for application id bundle_id.   � ��� �   R e t u r n   a n   N S D i c t i o n a r y   r e p r e s e n t a t i o n   o f   t h e   c u s t o m   k e y b o a r d   s h o r t c u t s   f o r   a p p l i c a t i o n   i d   b u n d l e _ i d .� ��� l     ������  � � � Like System Preferences, this retrieves the values from the sandboxed domain if the container exists, or the legacy domain if it does not.   � ���   L i k e   S y s t e m   P r e f e r e n c e s ,   t h i s   r e t r i e v e s   t h e   v a l u e s   f r o m   t h e   s a n d b o x e d   d o m a i n   i f   t h e   c o n t a i n e r   e x i s t s ,   o r   t h e   l e g a c y   d o m a i n   i f   i t   d o e s   n o t .� ��� l     ��������  ��  ��  � ��� l     ������  � x r Get the dictionary representation of the specified domain only (without using the standard defaults search path).   � ��� �   G e t   t h e   d i c t i o n a r y   r e p r e s e n t a t i o n   o f   t h e   s p e c i f i e d   d o m a i n   o n l y   ( w i t h o u t   u s i n g   t h e   s t a n d a r d   d e f a u l t s   s e a r c h   p a t h ) .� ��� r     ��� n    ��� I    ������� "0 getuserdefaults getUserDefaults� ���� o    ���� 0 	bundle_id  ��  ��  �  f     � o      ���� 0 user_defaults  � ��� Z   	 ?������ n  	 ��� I   
 ������� 20 applicationhascontainer applicationHasContainer� ���� o   
 ���� 0 	bundle_id  ��  ��  �  f   	 
� l   ���� r    ��� n   ��� I    ������� 40 persistentdomainforname_ persistentDomainForName_� ���� l   ������ n   ��� I    ������� (0 getsandboxeddomain getSandboxedDomain� ���� o    ���� 0 	bundle_id  ��  ��  �  f    ��  ��  ��  ��  � o    ���� 0 user_defaults  � o      ���� 0 dictionary_representation  �   Sandboxed application.   � ��� .   S a n d b o x e d   a p p l i c a t i o n .��  � l  " ?���� Z   " ?������ =  " %��� o   " #���� 0 	bundle_id  � m   # $�� ���  N S G l o b a l D o m a i n� r   ( /��� n  ( -��� I   ) -�������� 40 dictionaryrepresentation dictionaryRepresentation��  ��  � o   ( )���� 0 user_defaults  � o      ���� 0 dictionary_representation  ��  � l  2 ?���� r   2 ?   n  2 = I   3 =������ 40 persistentdomainforname_ persistentDomainForName_ �� l  3 9���� n  3 9 I   4 9��	���� "0 getlegacydomain getLegacyDomain	 
��
 o   4 5���� 0 	bundle_id  ��  ��    f   3 4��  ��  ��  ��   o   2 3���� 0 user_defaults   o      ���� 0 dictionary_representation  �   Legacy application.   � � (   L e g a c y   a p p l i c a t i o n .�   Not sandboxed.   � �    N o t   s a n d b o x e d .�  l  @ @��������  ��  ��    l  @ @����   ] W Return the dictionary represenation, or an empty dictionary if no shortcuts are found.    � �   R e t u r n   t h e   d i c t i o n a r y   r e p r e s e n a t i o n ,   o r   a n   e m p t y   d i c t i o n a r y   i f   n o   s h o r t c u t s   a r e   f o u n d .  Z   @ n�� =  @ C o   @ A���� 0 dictionary_representation   m   A B��
�� 
msng l  F O r   F O n  F M !  I   I M�������� 0 
dictionary  ��  ��  ! n  F I"#" o   G I���� 0 nsdictionary NSDictionary# m   F G��
�� misccura o      ���� 0 shortcut_dictionary   * $ The defaults domain does not exist.    �$$ H   T h e   d e f a u l t s   d o m a i n   d o e s   n o t   e x i s t .��   l  R n%&'% k   R n(( )*) r   R Z+,+ n  R X-.- I   S X��/���� 0 objectforkey_ objectForKey_/ 0��0 m   S T11 �22 ( N S U s e r K e y E q u i v a l e n t s��  ��  . o   R S���� 0 dictionary_representation  , o      ���� 0 shortcut_dictionary  * 3��3 Z  [ n45����4 =  [ ^676 o   [ \���� 0 shortcut_dictionary  7 m   \ ]��
�� 
msng5 r   a j898 n  a h:;: I   d h�������� 0 
dictionary  ��  ��  ; n  a d<=< o   b d���� 0 nsdictionary NSDictionary= m   a b��
�� misccura9 o      ���� 0 shortcut_dictionary  ��  ��  ��  & / ) The domain exists (but the key may not).   ' �>> R   T h e   d o m a i n   e x i s t s   ( b u t   t h e   k e y   m a y   n o t ) . ?��? L   o q@@ o   o p���� 0 shortcut_dictionary  ��  � ABA l     ��������  ��  ��  B CDC i  ? BEFE I      ��G���� J0 #setcustomkeyboardshortcutdictionary #setCustomKeyboardShortcutDictionaryG HIH o      ���� 0 	bundle_id  I J��J o      ���� 0 shortcut_dictionary  ��  ��  F k     DKK LML l     ��NO��  N q k Set the custom keyboard shortcuts for application id bundle_id using the NSDictionary shortcut_dictionary.   O �PP �   S e t   t h e   c u s t o m   k e y b o a r d   s h o r t c u t s   f o r   a p p l i c a t i o n   i d   b u n d l e _ i d   u s i n g   t h e   N S D i c t i o n a r y   s h o r t c u t _ d i c t i o n a r y .M QRQ l     ��ST��  S z t Like System Preferences, this sets the shortcuts in the legacy domain & sandboxed domain (if the container exists).   T �UU �   L i k e   S y s t e m   P r e f e r e n c e s ,   t h i s   s e t s   t h e   s h o r t c u t s   i n   t h e   l e g a c y   d o m a i n   &   s a n d b o x e d   d o m a i n   ( i f   t h e   c o n t a i n e r   e x i s t s ) .R VWV l     ��������  ��  ��  W XYX l     ��Z[��  Z   Get the user defaults.   [ �\\ .   G e t   t h e   u s e r   d e f a u l t s .Y ]^] r     _`_ n    aba I    ��c���� 20 applicationhascontainer applicationHasContainerc d��d o    ���� 0 	bundle_id  ��  ��  b  f     ` o      ���� 0 has_container  ^ efe r   	 ghg n  	 iji I   
 ��k���� "0 getuserdefaults getUserDefaultsk l��l n  
 mnm I    ��o���� "0 getlegacydomain getLegacyDomaino p��p o    ���� 0 	bundle_id  ��  ��  n  f   
 ��  ��  j  f   	 
h o      ���� 0 legacy_defaults  f qrq Z   ,st����s o    ���� 0 has_container  t r    (uvu n   &wxw I    &��y���� "0 getuserdefaults getUserDefaultsy z��z n   "{|{ I    "��}���� (0 getsandboxeddomain getSandboxedDomain} ~��~ o    ���� 0 	bundle_id  ��  ��  |  f    ��  ��  x  f    v o      ���� 0 sandboxed_defaults  ��  ��  r � l  - -��������  ��  ��  � ��� l  - -������  � , & Add the new custom keyboard shortcut.   � ��� L   A d d   t h e   n e w   c u s t o m   k e y b o a r d   s h o r t c u t .� ��� n  - 4��� I   . 4������� &0 setobject_forkey_ setObject_forKey_� ��� o   . /���� 0 shortcut_dictionary  � ���� m   / 0�� ��� ( N S U s e r K e y E q u i v a l e n t s��  ��  � o   - .���� 0 legacy_defaults  � ���� Z  5 D������ o   5 6�~�~ 0 has_container  � n  9 @��� I   : @�}��|�} &0 setobject_forkey_ setObject_forKey_� ��� o   : ;�{�{ 0 shortcut_dictionary  � ��z� m   ; <�� ��� ( N S U s e r K e y E q u i v a l e n t s�z  �|  � o   9 :�y�y 0 sandboxed_defaults  ��  �  ��  D ��� l     �x�w�v�x  �w  �v  � ��� i  C F��� I      �u��t�u 60 addcustomkeyboardshortcut addCustomKeyboardShortcut� ��� o      �s�s 0 	bundle_id  � ��� o      �r�r 0 
menu_title  � ��q� o      �p�p 0 keyboard_shortcut  �q  �t  � k     e�� ��� l     �o���o  � � � Add the custom keyboard shortcut keyboard_shortcut for menu item menu_title for application id bundle_id. If the menu item already has a keyboard shortcut, it will be updated to the new shortcut.   � ����   A d d   t h e   c u s t o m   k e y b o a r d   s h o r t c u t   k e y b o a r d _ s h o r t c u t   f o r   m e n u   i t e m   m e n u _ t i t l e   f o r   a p p l i c a t i o n   i d   b u n d l e _ i d .   I f   t h e   m e n u   i t e m   a l r e a d y   h a s   a   k e y b o a r d   s h o r t c u t ,   i t   w i l l   b e   u p d a t e d   t o   t h e   n e w   s h o r t c u t .� ��� l     �n���n  � > 8 The menu title is processed to handle menu hierarchies.   � ��� p   T h e   m e n u   t i t l e   i s   p r o c e s s e d   t o   h a n d l e   m e n u   h i e r a r c h i e s .� ��� l     �m���m  � y s Like System Preferences, this adds the shortcut to the legacy domain & sandboxed domain (if the container exists).   � ��� �   L i k e   S y s t e m   P r e f e r e n c e s ,   t h i s   a d d s   t h e   s h o r t c u t   t o   t h e   l e g a c y   d o m a i n   &   s a n d b o x e d   d o m a i n   ( i f   t h e   c o n t a i n e r   e x i s t s ) .� ��� l     �l�k�j�l  �k  �j  � ��� l     �i���i  �   Get the user defaults.   � ��� .   G e t   t h e   u s e r   d e f a u l t s .� ��� r     ��� n    ��� I    �h��g�h 20 applicationhascontainer applicationHasContainer� ��f� o    �e�e 0 	bundle_id  �f  �g  �  f     � o      �d�d 0 has_container  � ��� r   	 ��� n  	 ��� I   
 �c��b�c "0 getuserdefaults getUserDefaults� ��a� n  
 ��� I    �`��_�` "0 getlegacydomain getLegacyDomain� ��^� o    �]�] 0 	bundle_id  �^  �_  �  f   
 �a  �b  �  f   	 
� o      �\�\ 0 legacy_defaults  � ��� Z   ,���[�Z� o    �Y�Y 0 has_container  � r    (��� n   &��� I    &�X��W�X "0 getuserdefaults getUserDefaults� ��V� n   "��� I    "�U��T�U (0 getsandboxeddomain getSandboxedDomain� ��S� o    �R�R 0 	bundle_id  �S  �T  �  f    �V  �W  �  f    � o      �Q�Q 0 sandboxed_defaults  �[  �Z  � ��� l  - -�P�O�N�P  �O  �N  � ��� l  - -�M���M  � * $ Get the current keyboard shortcuts.   � ��� H   G e t   t h e   c u r r e n t   k e y b o a r d   s h o r t c u t s .� ��� r   - 5��� n  - 3��� I   . 3�L��K�L J0 #getcustomkeyboardshortcutdictionary #getCustomKeyboardShortcutDictionary� ��J� o   . /�I�I 0 	bundle_id  �J  �K  �  f   - .� o      �H�H 0 shortcut_dictionary  � ��� r   6 @��� n  6 >��� I   9 >�G��F�G 60 dictionarywithdictionary_ dictionaryWithDictionary_� ��E� o   9 :�D�D 0 shortcut_dictionary  �E  �F  � n  6 9��� o   7 9�C�C *0 nsmutabledictionary NSMutableDictionary� m   6 7�B
�B misccura� o      �A�A 0 mutable_dictionary  � ��� l  A A�@�?�>�@  �?  �>  � ��� l  A A�=���=  � , & Add the new custom keyboard shortcut.   � ��� L   A d d   t h e   n e w   c u s t o m   k e y b o a r d   s h o r t c u t .�    n  A M I   B M�<�;�< &0 setobject_forkey_ setObject_forKey_  o   B C�:�: 0 keyboard_shortcut   �9 l  C I�8�7 n  C I	
	 I   D I�6�5�6 "0 encodemenutitle encodeMenuTitle �4 o   D E�3�3 0 
menu_title  �4  �5  
  f   C D�8  �7  �9  �;   o   A B�2�2 0 mutable_dictionary    n  N U I   O U�1�0�1 &0 setobject_forkey_ setObject_forKey_  o   O P�/�/ 0 mutable_dictionary   �. m   P Q � ( N S U s e r K e y E q u i v a l e n t s�.  �0   o   N O�-�- 0 legacy_defaults   �, Z  V e�+�* o   V W�)�) 0 has_container   n  Z a I   [ a�(�'�( &0 setobject_forkey_ setObject_forKey_  o   [ \�&�& 0 mutable_dictionary   �% m   \ ]   �!! ( N S U s e r K e y E q u i v a l e n t s�%  �'   o   Z [�$�$ 0 sandboxed_defaults  �+  �*  �,  � "#" l     �#�"�!�#  �"  �!  # $%$ i  G J&'& I      � (��  <0 removecustomkeyboardshortcut removeCustomKeyboardShortcut( )*) o      �� 0 	bundle_id  * +�+ o      �� 0 
menu_title  �  �  ' k     x,, -.- l     �/0�  / a [ Remove the custom keyboard shortcut for menu item menu_title for application id bundle_id.   0 �11 �   R e m o v e   t h e   c u s t o m   k e y b o a r d   s h o r t c u t   f o r   m e n u   i t e m   m e n u _ t i t l e   f o r   a p p l i c a t i o n   i d   b u n d l e _ i d .. 232 l     �45�  4 > 8 The menu title is processed to handle menu hierarchies.   5 �66 p   T h e   m e n u   t i t l e   i s   p r o c e s s e d   t o   h a n d l e   m e n u   h i e r a r c h i e s .3 787 l     �9:�  9 � � Unlike System Preferences, this always removes the shortcut from the legacy domain & sandboxed domain (if the container exists).   : �;;   U n l i k e   S y s t e m   P r e f e r e n c e s ,   t h i s   a l w a y s   r e m o v e s   t h e   s h o r t c u t   f r o m   t h e   l e g a c y   d o m a i n   &   s a n d b o x e d   d o m a i n   ( i f   t h e   c o n t a i n e r   e x i s t s ) .8 <=< l     ����  �  �  = >?> l     �@A�  @   Get the user defaults.   A �BB .   G e t   t h e   u s e r   d e f a u l t s .? CDC r     EFE n    GHG I    �I�� 20 applicationhascontainer applicationHasContainerI J�J o    �� 0 	bundle_id  �  �  H  f     F o      �� 0 has_container  D KLK r   	 MNM n  	 OPO I   
 �Q�� "0 getuserdefaults getUserDefaultsQ R�R n  
 STS I    �U�� "0 getlegacydomain getLegacyDomainU V�
V o    �	�	 0 	bundle_id  �
  �  T  f   
 �  �  P  f   	 
N o      �� 0 legacy_defaults  L WXW Z   ,YZ��Y o    �� 0 has_container  Z r    ([\[ n   &]^] I    &�_�� "0 getuserdefaults getUserDefaults_ `�` n   "aba I    "�c� � (0 getsandboxeddomain getSandboxedDomainc d��d o    ���� 0 	bundle_id  ��  �   b  f    �  �  ^  f    \ o      ���� 0 sandboxed_defaults  �  �  X efe l  - -��������  ��  ��  f ghg l  - -��ij��  i * $ Get the current keyboard shortcuts.   j �kk H   G e t   t h e   c u r r e n t   k e y b o a r d   s h o r t c u t s .h lml r   - 5non n  - 3pqp I   . 3��r���� J0 #getcustomkeyboardshortcutdictionary #getCustomKeyboardShortcutDictionaryr s��s o   . /���� 0 	bundle_id  ��  ��  q  f   - .o o      ���� 0 shortcut_dictionary  m tut r   6 @vwv n  6 >xyx I   9 >��z���� 60 dictionarywithdictionary_ dictionaryWithDictionary_z {��{ o   9 :���� 0 shortcut_dictionary  ��  ��  y n  6 9|}| o   7 9���� *0 nsmutabledictionary NSMutableDictionary} m   6 7��
�� misccuraw o      ���� 0 mutable_dictionary  u ~~ l  A A��������  ��  ��   ��� l  A A������  � + % Remove the custom keyboard shortcut.   � ��� J   R e m o v e   t h e   c u s t o m   k e y b o a r d   s h o r t c u t .� ��� n  A L��� I   B L������� *0 removeobjectforkey_ removeObjectForKey_� ���� l  B H������ n  B H��� I   C H������� "0 encodemenutitle encodeMenuTitle� ���� o   C D���� 0 
menu_title  ��  ��  �  f   B C��  ��  ��  ��  � o   A B���� 0 mutable_dictionary  � ��� Z  M `������� =  M V��� c   M T��� n  M R��� I   N R�������� 	0 count  ��  ��  � o   M N���� 0 mutable_dictionary  � m   R S��
�� 
long� m   T U����  � r   Y \��� m   Y Z��
�� 
msng� o      ���� 0 mutable_dictionary  ��  ��  � ��� n  a h��� I   b h������� &0 setobject_forkey_ setObject_forKey_� ��� o   b c���� 0 mutable_dictionary  � ���� m   c d�� ��� ( N S U s e r K e y E q u i v a l e n t s��  ��  � o   a b���� 0 legacy_defaults  � ���� Z  i x������� o   i j���� 0 has_container  � n  m t��� I   n t������� &0 setobject_forkey_ setObject_forKey_� ��� o   n o���� 0 mutable_dictionary  � ���� m   o p�� ��� ( N S U s e r K e y E q u i v a l e n t s��  ��  � o   m n���� 0 sandboxed_defaults  ��  ��  ��  % ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l     ������  � , & Formatting custom keyboard shortcuts.   � ��� L   F o r m a t t i n g   c u s t o m   k e y b o a r d   s h o r t c u t s .� ��� i  K N��� I      ������� "0 encodemenutitle encodeMenuTitle� ���� o      ���� 0 
menu_title  ��  ��  � k     �� ��� l     ������  � v p Convert the plain-text representation of menu hierarchie menu_title (e.g. "File->Save") to its escaped version.   � ��� �   C o n v e r t   t h e   p l a i n - t e x t   r e p r e s e n t a t i o n   o f   m e n u   h i e r a r c h i e   m e n u _ t i t l e   ( e . g .   " F i l e - > S a v e " )   t o   i t s   e s c a p e d   v e r s i o n .� ���� Z     ������ E     ��� o     ���� 0 
menu_title  � m    �� ���  - >� L    �� b    ��� 5    �����
�� 
cha � m    	���� 
�� kfrmID  � n   ��� I    ������� 0 replacetext replaceText� ��� o    ���� 0 
menu_title  � ��� m    �� ���  - >� ���� 5    �����
�� 
cha � m    ���� 
�� kfrmID  ��  ��  �  f    ��  � L    �� o    ���� 0 
menu_title  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l     ������  �   Library helpers.   � ��� "   L i b r a r y   h e l p e r s .� ��� i  O R��� I      ������� 0 
fileexists 
fileExists� ���� o      ���� 0 file_specifier  ��  ��  � k     ,�� ��� Q     )���� k    �� ��� l   ������ c    ��� l   ������ c    ��� o    ���� 0 file_specifier  � m    ��
�� 
furl��  ��  � m    ��
�� 
alis��  ��  � ���� L   	 �� m   	 
��
�� boovtrue��  � R      �����
�� .ascrerr ****      � ****��  � �����
�� 
errn� d         m      �������  � Q    )�� w      k       l   ���� c    	
	 l   ���� n     1    ��
�� 
ppth o    ���� 0 file_specifier  ��  ��  
 m    ��
�� 
alis��  ��   �� L      m    ��
�� boovtrue��  �                                                                                  sevs  alis    \  Macintosh HD               �yCKBD ����System Events.app                                              �����yCK        ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��   R      ������
�� .ascrerr ****      � ****��  ��  ��  � �� L   * , m   * +��
�� boovfals��  �  l     ��������  ��  ��    i  S V I      ������  0 getuniqueitems getUniqueItems � o      �~�~ 0 l L�  ��   k     2  r      J     �}�}   o      �|�| 0 unique_items     X    /!�{"! k    *## $%$ r    &'& n    ()( 1    �z
�z 
pcnt) o    �y�y 0 an_item  ' o      �x�x 0 an_item  % *�w* Z   *+,�v�u+ H    -- E   ./. o    �t�t 0 unique_items  / o    �s�s 0 an_item  , r   " &010 o   " #�r�r 0 an_item  1 l     2�q�p2 n      343  ;   $ %4 o   # $�o�o 0 unique_items  �q  �p  �v  �u  �w  �{ 0 an_item  " o    	�n�n 0 l L  5�m5 L   0 266 o   0 1�l�l 0 unique_items  �m   787 l     �k�j�i�k  �j  �i  8 9:9 i  W Z;<; I      �h=�g�h 00 makelistbyremovingitem makeListByRemovingItem= >?> o      �f�f 0 l L? @�e@ o      �d�d 0 o O�e  �g  < k     2AA BCB r     DED n     FGF 1    �c
�c 
lengG o     �b�b 0 l LE o      �a�a 0 l_length L_lengthC HIH r    
JKJ J    �`�`  K o      �_�_ 0 new_l new_LI LML Y    /N�^OP�]N k    *QQ RSR r    TUT n    VWV 4    �\X
�\ 
cobjX o    �[�[ 0 i  W o    �Z�Z 0 l LU o      �Y�Y 0 l_item L_itemS Y�XY Z   *Z[�W�VZ >   \]\ o    �U�U 0 l_item L_item] o    �T�T 0 o O[ r   " &^_^ o   " #�S�S 0 l_item L_item_ l     `�R�Q` n      aba  ;   $ %b o   # $�P�P 0 new_l new_L�R  �Q  �W  �V  �X  �^ 0 i  O m    �O�O P o    �N�N 0 l_length L_length�]  M c�Mc L   0 2dd o   0 1�L�L 0 new_l new_L�M  : efe l     �K�J�I�K  �J  �I  f g�Hg i  [ ^hih I      �Gj�F�G 0 replacetext replaceTextj klk o      �E�E 0 s  l mnm o      �D�D 0 search_string  n o�Co o      �B�B 0 replacement_string  �C  �F  i k     &pp qrq r     sts n    uvu 1    �A
�A 
txdlv 1     �@
�@ 
ascrt o      �?�? 0 previous_tids previous_TIDsr wxw r    yzy o    �>�> 0 search_string  z n     {|{ 1    
�=
�= 
txdl| 1    �<
�< 
ascrx }~} r    � n    ��� 2   �;
�; 
citm� o    �:�: 0 s  � o      �9�9 0 s_text_items  ~ ��� r    ��� o    �8�8 0 replacement_string  � n     ��� 1    �7
�7 
txdl� 1    �6
�6 
ascr� ��� r    ��� c    ��� o    �5�5 0 s_text_items  � m    �4
�4 
TEXT� o      �3�3 0 s  � ��� r    #��� o    �2�2 0 previous_tids previous_TIDs� n     ��� 1     "�1
�1 
txdl� 1     �0
�0 
ascr� ��/� L   $ &�� o   $ %�.�. 0 s  �/  �H       �-���������������������-  � �,�+�*�)�(�'�&�%�$�#�"�!� ������
�, 
pimr�+ "0 getuserdefaults getUserDefaults�* 20 applicationhascontainer applicationHasContainer�) "0 getlegacydomain getLegacyDomain�( (0 getsandboxeddomain getSandboxedDomain�' T0 (getguicustomkeyboardshortcutapplications (getGUICustomKeyboardShortcutApplications�& T0 (setguicustomkeyboardshortcutapplications (setGUICustomKeyboardShortcutApplications�% T0 (hasguicustomkeyboardshortcutapplications (hasGUICustomKeyboardShortcutApplications�$ R0 'addguicustomkeyboardshortcutapplication 'addGUICustomKeyboardShortcutApplication�# X0 *removeguicustomkeyboardshortcutapplication *removeGUICustomKeyboardShortcutApplication�" J0 #getcustomkeyboardshortcutdictionary #getCustomKeyboardShortcutDictionary�! J0 #setcustomkeyboardshortcutdictionary #setCustomKeyboardShortcutDictionary�  60 addcustomkeyboardshortcut addCustomKeyboardShortcut� <0 removecustomkeyboardshortcut removeCustomKeyboardShortcut� "0 encodemenutitle encodeMenuTitle� 0 
fileexists 
fileExists�  0 getuniqueitems getUniqueItems� 00 makelistbyremovingitem makeListByRemovingItem� 0 replacetext replaceText� ��� �  ��� ���
� 
cobj� ��   �
� 
osax�  � ���
� 
cobj� ��   � 
� 
frmk�  � � /������ "0 getuserdefaults getUserDefaults� ��� �  �� 
0 domain  �  � �� 
0 domain  �  > B��
�	�
� misccura�
  0 nsuserdefaults NSUserDefaults�	 	0 alloc  � (0 initwithsuitename_ initWithSuiteName_� ��  �E�Y hO��,j+ �k+ � � Z������ 20 applicationhascontainer applicationHasContainer� ��� �  �� 0 	bundle_id  �  � �� 0 	bundle_id  � � ���� s u��
�  afdrcusr
�� .earsffdralis        afdr
�� 
psxp�� 0 
fileexists 
fileExists� )�j �,�%�%�%k+ � �� |���������� "0 getlegacydomain getLegacyDomain�� ����� �  ���� 0 	bundle_id  ��  � ���� 0 	bundle_id  �  � ������� �
�� afdrcusr
�� .earsffdralis        afdr
�� 
psxp�� ��  �E�Y hO�j �,�%�%� �� ����������� (0 getsandboxeddomain getSandboxedDomain�� ����� �  ���� 0 	bundle_id  ��  � ���� 0 	bundle_id  � ������ � �
�� afdrcusr
�� .earsffdralis        afdr
�� 
psxp�� �j �,�%�%�%�%� �� ����������� T0 (getguicustomkeyboardshortcutapplications (getGUICustomKeyboardShortcutApplications��  ��  � ���� 0 gui_defaults  �  ��� ������� "0 getuserdefaults getUserDefaults�� (0 stringarrayforkey_ stringArrayForKey_
�� 
list�� )�k+ E�O��k+ �&� �� ����������� T0 (setguicustomkeyboardshortcutapplications (setGUICustomKeyboardShortcutApplications�� ����� �  ���� 0 
bundle_ids  ��  � ������ 0 
bundle_ids  �� 0 gui_defaults  �  �����	���� "0 getuserdefaults getUserDefaults��  0 getuniqueitems getUniqueItems�� &0 setobject_forkey_ setObject_forKey_�� )�k+ E�O�)�k+ �l+ � ������������ T0 (hasguicustomkeyboardshortcutapplications (hasGUICustomKeyboardShortcutApplications�� ����� �  ���� 0 	bundle_id  ��  � ���� 0 	bundle_id  � ���� T0 (getguicustomkeyboardshortcutapplications (getGUICustomKeyboardShortcutApplications�� )j+  �kv� ��&���������� R0 'addguicustomkeyboardshortcutapplication 'addGUICustomKeyboardShortcutApplication�� ����� �  ���� 0 	bundle_id  ��  � �������� 0 	bundle_id  �� 0 gui_defaults  �� 0 gui_bundle_ids  � 7��D����Y���� "0 getuserdefaults getUserDefaults�� (0 stringarrayforkey_ stringArrayForKey_
�� 
list�� &0 setobject_forkey_ setObject_forKey_�� -)�k+ E�O��k+ �&E�O��kv ���kv%�l+ Y h� ��`���������� X0 *removeguicustomkeyboardshortcutapplication *removeGUICustomKeyboardShortcutApplication�� ����� �  ���� 0 	bundle_id  ��  � �������� 0 	bundle_id  �� 0 gui_defaults  �� 0 gui_bundle_ids  � q��~���������������� "0 getuserdefaults getUserDefaults�� (0 stringarrayforkey_ stringArrayForKey_
�� 
list
�� 
leng
�� 
msng�� &0 setobject_forkey_ setObject_forKey_�� 00 makelistbyremovingitem makeListByRemovingItem�� @)�k+ E�O��k+ �&E�O��kv $��,k  ���l+ Y �)��l+ 	�l+ Y h� ������������� J0 #getcustomkeyboardshortcutdictionary #getCustomKeyboardShortcutDictionary�� ����� �  ���� 0 	bundle_id  ��  � ���������� 0 	bundle_id  �� 0 user_defaults  �� 0 dictionary_representation  �� 0 shortcut_dictionary  � ���������������������1���� "0 getuserdefaults getUserDefaults�� 20 applicationhascontainer applicationHasContainer�� (0 getsandboxeddomain getSandboxedDomain�� 40 persistentdomainforname_ persistentDomainForName_�� 40 dictionaryrepresentation dictionaryRepresentation�� "0 getlegacydomain getLegacyDomain
�� 
msng
�� misccura�� 0 nsdictionary NSDictionary�� 0 
dictionary  �� 0 objectforkey_ objectForKey_�� r)�k+  E�O)�k+  �)�k+ k+ E�Y ��  �j+ E�Y �)�k+ k+ E�O��  ��,j+ 
E�Y ��k+ E�O��  ��,j+ 
E�Y hO�� ��F���������� J0 #setcustomkeyboardshortcutdictionary #setCustomKeyboardShortcutDictionary�� ����� �  ������ 0 	bundle_id  �� 0 shortcut_dictionary  ��  � ������������ 0 	bundle_id  �� 0 shortcut_dictionary  �� 0 has_container  �� 0 legacy_defaults  �� 0 sandboxed_defaults  � �������������� 20 applicationhascontainer applicationHasContainer�� "0 getlegacydomain getLegacyDomain�� "0 getuserdefaults getUserDefaults�� (0 getsandboxeddomain getSandboxedDomain�� &0 setobject_forkey_ setObject_forKey_�� E)�k+  E�O))�k+ k+ E�O� ))�k+ k+ E�Y hO���l+ O� ���l+ Y h� ������������� 60 addcustomkeyboardshortcut addCustomKeyboardShortcut�� ����� �  �������� 0 	bundle_id  �� 0 
menu_title  �� 0 keyboard_shortcut  ��  � ��������~�}�|�{�� 0 	bundle_id  �� 0 
menu_title  �� 0 keyboard_shortcut  � 0 has_container  �~ 0 legacy_defaults  �} 0 sandboxed_defaults  �| 0 shortcut_dictionary  �{ 0 mutable_dictionary  � �z�y�x�w�v�u�t�s�r�q �z 20 applicationhascontainer applicationHasContainer�y "0 getlegacydomain getLegacyDomain�x "0 getuserdefaults getUserDefaults�w (0 getsandboxeddomain getSandboxedDomain�v J0 #getcustomkeyboardshortcutdictionary #getCustomKeyboardShortcutDictionary
�u misccura�t *0 nsmutabledictionary NSMutableDictionary�s 60 dictionarywithdictionary_ dictionaryWithDictionary_�r "0 encodemenutitle encodeMenuTitle�q &0 setobject_forkey_ setObject_forKey_�� f)�k+  E�O))�k+ k+ E�O� ))�k+ k+ E�Y hO)�k+ E�O��,�k+ E�O��)�k+ l+ 	O���l+ 	O� ���l+ 	Y h� �p'�o�n���m�p <0 removecustomkeyboardshortcut removeCustomKeyboardShortcut�o �l��l �  �k�j�k 0 	bundle_id  �j 0 
menu_title  �n  � �i�h�g�f�e�d�c�i 0 	bundle_id  �h 0 
menu_title  �g 0 has_container  �f 0 legacy_defaults  �e 0 sandboxed_defaults  �d 0 shortcut_dictionary  �c 0 mutable_dictionary  � �b�a�`�_�^�]�\�[�Z�Y�X�W�V��U��b 20 applicationhascontainer applicationHasContainer�a "0 getlegacydomain getLegacyDomain�` "0 getuserdefaults getUserDefaults�_ (0 getsandboxeddomain getSandboxedDomain�^ J0 #getcustomkeyboardshortcutdictionary #getCustomKeyboardShortcutDictionary
�] misccura�\ *0 nsmutabledictionary NSMutableDictionary�[ 60 dictionarywithdictionary_ dictionaryWithDictionary_�Z "0 encodemenutitle encodeMenuTitle�Y *0 removeobjectforkey_ removeObjectForKey_�X 	0 count  
�W 
long
�V 
msng�U &0 setobject_forkey_ setObject_forKey_�m y)�k+  E�O))�k+ k+ E�O� ))�k+ k+ E�Y hO)�k+ E�O��,�k+ E�O�)�k+ k+ 	O�j+ 
�&j  �E�Y hO���l+ O� ���l+ Y h� �T��S�R���Q�T "0 encodemenutitle encodeMenuTitle�S �P��P �  �O�O 0 
menu_title  �R  � �N�N 0 
menu_title  � ��M�L�K��J
�M 
cha �L 
�K kfrmID  �J 0 replacetext replaceText�Q �� )���0)��)���0m+ %Y �� �I��H�G���F�I 0 
fileexists 
fileExists�H �E��E �  �D�D 0 file_specifier  �G  � �C�C 0 file_specifier  � �B�A�@��?�>
�B 
furl
�A 
alis�@  � �=�<�;
�= 
errn�<�\�;  
�? 
ppth�>  �F - ��&�&OeW X   �Z��,�&OeW X  hOf� �:�9�8���7�:  0 getuniqueitems getUniqueItems�9 �6��6 �  �5�5 0 l L�8  � �4�3�2�4 0 l L�3 0 unique_items  �2 0 an_item  � �1�0�/�.
�1 
kocl
�0 
cobj
�/ .corecnte****       ****
�. 
pcnt�7 3jvE�O )�[��l kh ��,E�O�� 	��6FY h[OY��O�� �-<�,�+���*�- 00 makelistbyremovingitem makeListByRemovingItem�, �)��) �  �(�'�( 0 l L�' 0 o O�+  � �&�%�$�#�"�!�& 0 l L�% 0 o O�$ 0 l_length L_length�# 0 new_l new_L�" 0 i  �! 0 l_item L_item� � �
�  
leng
� 
cobj�* 3��,E�OjvE�O #k�kh ��/E�O�� 	��6FY h[OY��O�� �i������ 0 replacetext replaceText� ��� �  ���� 0 s  � 0 search_string  � 0 replacement_string  �  � ������ 0 s  � 0 search_string  � 0 replacement_string  � 0 previous_tids previous_TIDs� 0 s_text_items  � ����
� 
ascr
� 
txdl
� 
citm
� 
TEXT� '��,E�O���,FO��-E�O���,FO��&E�O���,FO�ascr  ��ޭ