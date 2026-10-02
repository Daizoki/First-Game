# Generates scenes/round.tscn (the round screen layout). Run from the project root:
#   python3 tools/gen_round.py

def node(name, typ, parent=None, props=None, unique=False, script=None, instance=None):
    head = f'[node name="{name}"'
    if typ: head += f' type="{typ}"'
    if parent is not None: head += f' parent="{parent}"'
    if instance: head += f' instance=ExtResource("{instance}")'
    head += ']'
    lines=[head]
    if unique: lines.append('unique_name_in_owner = true')
    props=dict(props or {})
    script_vars={k:props.pop(k) for k in list(props) if k in ("style","slots","show_rope")}
    for k,v in props.items(): lines.append(f'{k} = {v}')
    if script: lines.append(f'script = ExtResource("{script}")')
    for k,v in script_vars.items(): lines.append(f'{k} = {v}')
    return "\n".join(lines)+"\n"

def tid(props, value):
    p=dict(props); p["metadata/tutorial_id"]=f'"{value}"'; return p

def rect(x,y,w,h):
    return {"layout_mode":"1","offset_left":f"{x:.1f}","offset_top":f"{y:.1f}","offset_right":f"{x+w:.1f}","offset_bottom":f"{y+h:.1f}"}

FULL={"layout_mode":"1","anchors_preset":"15","anchor_right":"1.0","anchor_bottom":"1.0","grow_horizontal":"2","grow_vertical":"2"}
def label(name,parent,text,size=None,var=None,color=None,align=None,extra=None):
    p={"layout_mode":"2"}
    if var: p["theme_type_variation"]=f'&"{var}"'
    if color: p["theme_override_colors/font_color"]=color
    if size: p["theme_override_font_sizes/font_size"]=str(size)
    p["text"]=f'"{text}"'
    if align is not None: p["horizontal_alignment"]=str(align)
    if extra: p.update(extra)
    return node(name,"Label",parent,p,unique=True)

ext=[("Script","res://scripts/ui/round_screen.gd","1_round"),("Script","res://scripts/ui/night_backdrop.gd","2_backdrop"),
     ("Script","res://scripts/ui/candle_row.gd","3_candles"),("Script","res://scripts/ui/portrait.gd","4_portrait"),
     ("Script","res://scripts/ui/rune_circle.gd","5_circle"),("Script","res://scripts/ui/talisman_string.gd","6_string"),
     ("Script","res://scripts/ui/hand_view.gd","7_hand"),("Script","res://scripts/ui/float_layer.gd","8_float"),
     ("PackedScene","res://scenes/spell_reveal.tscn","9_reveal"),("Script","res://scripts/ui/classroom_backdrop.gd","10_classroom"),
     ("Script","res://scripts/ui/word_book.gd","11_word_book"),
     ("Script","res://scripts/ui/rune_book.gd","12_rune_book")]
subs='''[sub_resource type="StyleBoxFlat" id="bar_bg"]
bg_color = Color(0.0588235, 0.0509804, 0.109804, 1)
border_width_left = 3
border_width_top = 3
border_width_right = 3
border_width_bottom = 3
border_color = Color(0.0196078, 0.0235294, 0.0392157, 1)
corner_radius_top_left = 6
corner_radius_top_right = 6
corner_radius_bottom_right = 6
corner_radius_bottom_left = 6

[sub_resource type="StyleBoxFlat" id="bar_fill"]
bg_color = Color(1, 0.415686, 0.239216, 1)
corner_radius_top_left = 6
corner_radius_top_right = 6
corner_radius_bottom_right = 6
corner_radius_bottom_left = 6
shadow_color = Color(1, 0.415686, 0.239216, 0.4)
shadow_size = 8
'''
out=[f'[gd_scene load_steps={len(ext)+3} format=3]\n']
for t,p,i in ext: out.append(f'[ext_resource type="{t}" path="{p}" id="{i}"]')
out.append("")
out.append(subs)
out.append(node("Round","Control",None,dict(FULL,layout_mode="3"),script="1_round"))
out.append(node("Backdrop","Control",".",dict(FULL,mouse_filter="2"),unique=True,script="2_backdrop"))
out.append(node("Classroom","Control",".",dict(FULL,mouse_filter="2",visible="false"),unique=True,script="10_classroom"))

# --- left column: info, score, Power x Resonance, candles, chalk, sort
out.append(node("Info","VBoxContainer",".",dict(rect(40,18,400,214),**{"theme_override_constants/separation":"2"})))
out.append(label("TrialLabel","Info","Rundă",38,"TitleLabel"))
out.append(node("InfoGrid","GridContainer","Info",{"layout_mode":"2","columns":"2","theme_override_constants/h_separation":"18","theme_override_constants/v_separation":"0"}))
out.append(label("CoinsLabel","Info/InfoGrid","Monede",26,"SecondaryLabel"))
out.append(label("CoinsValue","Info/InfoGrid","0",28,color="Color(0.921569, 0.666667, 0.235294, 1)"))
out.append(label("BagLabel","Info/InfoGrid","Săculeț",26,"SecondaryLabel"))
out.append(label("BagValue","Info/InfoGrid","40 / 48",28))
out.append(label("SeedLabel","Info","Seed",18,"SecondaryLabel"))
out.append(node("TopButtons","HBoxContainer","Info",{"layout_mode":"2","theme_override_constants/separation":"10"}))
out.append(node("SpeedButton","Button","Info/TopButtons",{"custom_minimum_size":"Vector2(160, 44)","layout_mode":"2","theme_override_font_sizes/font_size":"22","text":'"x1"'},unique=True))
out.append(node("MenuButton","Button","Info/TopButtons",{"metadata/tutorial_id":'"btn_menu"',"custom_minimum_size":"Vector2(120, 44)","layout_mode":"2","theme_override_font_sizes/font_size":"22","text":'"Menu"'},unique=True))

out.append(node("ScorePanel","PanelContainer",".",tid(rect(40,250,400,180),"score")))
out.append(node("ScoreBox","VBoxContainer","ScorePanel",{"layout_mode":"2","theme_override_constants/separation":"0"}))
out.append(label("ScoreValue","ScorePanel/ScoreBox","0",72,align=0,extra={"theme_override_constants/line_spacing":"-10"}))
out.append(label("ScoreTarget","ScorePanel/ScoreBox","din 1 500",26,"SecondaryLabel"))
out.append(node("ScoreBar","ProgressBar","ScorePanel/ScoreBox",{"unique_name_in_owner":"true","custom_minimum_size":"Vector2(0, 22)","layout_mode":"2","theme_override_styles/background":'SubResource("bar_bg")',"theme_override_styles/fill":'SubResource("bar_fill")',"show_percentage":"false"}))
out.append(node("PowerRes","HBoxContainer",".",dict(tid(rect(40,446,400,84),"power_res"),**{"theme_override_constants/separation":"10","alignment":"1"})))
out.append(node("PowerBox","PanelContainer","PowerRes",{"custom_minimum_size":"Vector2(165, 0)","layout_mode":"2","theme_type_variation":'&"BonePanel"'}))
out.append(label("PowerValue","PowerRes/PowerBox","0",52,color="Color(0.0196078, 0.0235294, 0.0392157, 1)",align=1))
out.append(node("Times","Label","PowerRes",{"layout_mode":"2","theme_override_font_sizes/font_size":"48","text":'"×"'}))
out.append(node("ResBox","PanelContainer","PowerRes",{"custom_minimum_size":"Vector2(165, 0)","layout_mode":"2","theme_type_variation":'&"EmberPanel"'}))
out.append(label("ResValue","PowerRes/ResBox","0",52,color="Color(1, 0.415686, 0.239216, 1)",align=1,extra={"theme_override_colors/font_outline_color":"Color(1, 0.701961, 0.278431, 0.35)","theme_override_constants/outline_size":"6"}))
out.append(node("CastsLabel","Label",".",dict(rect(40,544,300,34),**{"theme_type_variation":'&"SecondaryLabel"',"theme_override_font_sizes/font_size":"24","text":'"Rostiri"'}),unique=True))
out.append(node("Candles","Control",".",dict(tid(rect(40,572,330,124),"candles"),mouse_filter="2"),unique=True,script="3_candles"))
out.append(node("SwapsLabel","Label",".",dict(rect(40,706,300,34),**{"theme_type_variation":'&"SecondaryLabel"',"theme_override_font_sizes/font_size":"24","text":'"Schimbări"'}),unique=True))
out.append(node("Chalk","Control",".",dict(tid(rect(40,738,240,64),"chalk"),mouse_filter="2",style="1"),unique=True,script="3_candles"))
out.append(node("SortBox","VBoxContainer",".",tid(rect(40,872,250,170),"sort")))
out.append(label("SortLabel","SortBox","Sortează",24,"SecondaryLabel"))
out.append(node("SortPositionButton","Button","SortBox",{"custom_minimum_size":"Vector2(220, 52)","layout_mode":"2","theme_override_font_sizes/font_size":"24","text":'"Poziție"'},unique=True))
out.append(node("SortKinButton","Button","SortBox",{"custom_minimum_size":"Vector2(220, 52)","layout_mode":"2","theme_override_font_sizes/font_size":"24","text":'"Neam"'},unique=True))

# --- top center: examiner card
out.append(node("ExaminerCard","PanelContainer",".",tid(rect(620,14,680,222),"examiner")))
out.append(node("CardRow","HBoxContainer","ExaminerCard",{"layout_mode":"2","theme_override_constants/separation":"18"}))
out.append(node("Portrait","Control","ExaminerCard/CardRow",{"custom_minimum_size":"Vector2(140, 140)","layout_mode":"2","size_flags_vertical":"4","mouse_filter":"2"},unique=True,script="4_portrait"))
out.append(node("CardText","VBoxContainer","ExaminerCard/CardRow",{"layout_mode":"2","size_flags_horizontal":"3","theme_override_constants/separation":"2"}))
out.append(label("ExaminerName","ExaminerCard/CardRow/CardText","Nume",40,"TitleLabel"))
out.append(label("ExaminerRole","ExaminerCard/CardRow/CardText","rol",22,"SecondaryLabel"))
out.append(node("RuleBox","PanelContainer","ExaminerCard/CardRow/CardText",{"layout_mode":"2","theme_type_variation":'&"RulePanel"'}))
out.append(label("RuleText","ExaminerCard/CardRow/CardText/RuleBox","regula",20,extra={"autowrap_mode":"3"}))
out.append(label("TargetLabel","ExaminerCard/CardRow/CardText","Ținta",30,color="Color(1, 0.701961, 0.278431, 1)",extra={"metadata/tutorial_id":'"target"'}))

# --- center: rune circle
out.append(node("RuneCircle","Control",".",tid(rect(725,248,470,470),"circle"),unique=True,script="5_circle"))
out.append(node("CircleText","VBoxContainer","RuneCircle",{"layout_mode":"1","anchors_preset":"8","anchor_left":"0.5","anchor_top":"0.5","anchor_right":"0.5","anchor_bottom":"0.5","offset_left":"-150.0","offset_top":"-120.0","offset_right":"150.0","offset_bottom":"120.0","grow_horizontal":"2","grow_vertical":"2","mouse_filter":"2","alignment":"1","theme_override_constants/separation":"2"}))
out.append(label("WordName","RuneCircle/CircleText","Alege",44,"TitleLabel",align=1))
out.append(label("WordLevel","RuneCircle/CircleText","",20,"SecondaryLabel",align=1))
out.append(label("ScoringCount","RuneCircle/CircleText","",22,"SecondaryLabel",align=1))
out.append(label("PreviewValue","RuneCircle/CircleText","",40,align=1))
out.append(label("SpellLine","RuneCircle/CircleText","",22,align=1,extra={"autowrap_mode":"3"}))

out.append(node("WordBookButton","Button",".",dict(tid(rect(1222,486,200,60),"btn_word_book"),**{"theme_override_font_sizes/font_size":"26","text":'"Cuvinte"'}),unique=True))

# --- right: talismans, consumables, Kenaz
out.append(node("Talismans","Control",".",dict(rect(1320,14,580,210),mouse_filter="2"),unique=True,script="6_string"))
out.append(node("Consumables","Control",".",dict(rect(1600,262,290,190),mouse_filter="2",slots="2",show_rope="false"),unique=True,script="6_string"))
out.append(node("KenazPanel","VBoxContainer",".",dict(tid(rect(1400,560,500,120),"kenaz"),mouse_filter="2"),unique=True))
out.append(label("KenazLabel","KenazPanel","Kenaz",22,"SecondaryLabel",align=1))
out.append(node("KenazStones","HBoxContainer","KenazPanel",{"layout_mode":"2","alignment":"1","theme_override_constants/separation":"14"},unique=True))

# --- bottom: hand and actions
out.append(node("Hand","Control",".",tid(rect(310,690,1310,390),"hand"),unique=True,script="7_hand"))
out.append(node("Actions","VBoxContainer",".",dict(rect(1640,818,250,222),**{"theme_override_constants/separation":"14","alignment":"2"})))
out.append(node("CastButton","Button","Actions",{"custom_minimum_size":"Vector2(250, 110)","layout_mode":"2","theme_type_variation":'&"CastButton"',"text":'"Rostește"',"metadata/tutorial_id":'"btn_cast"'},unique=True))
out.append(node("SwapButton","Button","Actions",{"custom_minimum_size":"Vector2(250, 64)","layout_mode":"2","text":'"Schimbă"',"metadata/tutorial_id":'"btn_swap"'},unique=True))

# --- overlays
out.append(node("FloatLayer","Control",".",dict(FULL,mouse_filter="2"),unique=True,script="8_float"))
out.append(node("Toast","Label",".",dict(rect(460,722,1000,56),**{"theme_override_font_sizes/font_size":"34","theme_override_colors/font_color":"Color(1, 0.701961, 0.278431, 1)","theme_override_colors/font_outline_color":"Color(0.0196078, 0.0235294, 0.0392157, 1)","theme_override_constants/outline_size":"10","text":'"toast"',"horizontal_alignment":"1"}),unique=True))
out.append(node("SpellReveal",None,".",FULL,unique=True,instance="9_reveal"))
out.append(node("ResultPanel","PanelContainer",".",{"visible":"false","layout_mode":"1","anchors_preset":"8","anchor_left":"0.5","anchor_top":"0.5","anchor_right":"0.5","anchor_bottom":"0.5","offset_left":"-400.0","offset_top":"-210.0","offset_right":"400.0","offset_bottom":"210.0","grow_horizontal":"2","grow_vertical":"2"},unique=True))
out.append(node("ResultBox","VBoxContainer","ResultPanel",{"layout_mode":"2","alignment":"1","theme_override_constants/separation":"16"}))
out.append(label("ResultTitle","ResultPanel/ResultBox","Rezultat",72,"TitleLabel",align=1))
out.append(label("ResultScore","ResultPanel/ResultBox","scor",34,align=1))
out.append(label("ResultMoney","ResultPanel/ResultBox","",26,color="Color(0.921569, 0.666667, 0.235294, 1)",align=1))
out.append(node("ResultButtons","HBoxContainer","ResultPanel/ResultBox",{"layout_mode":"2","alignment":"1","theme_override_constants/separation":"20"}))
out.append(node("AgainButton","Button","ResultPanel/ResultBox/ResultButtons",{"custom_minimum_size":"Vector2(320, 72)","layout_mode":"2","theme_type_variation":'&"CastButton"',"theme_override_font_sizes/font_size":"32","text":'"Again"'},unique=True))
out.append(node("ResultMenuButton","Button","ResultPanel/ResultBox/ResultButtons",{"custom_minimum_size":"Vector2(220, 72)","layout_mode":"2","text":'"Menu"'},unique=True))
out.append(node("WordBook","Control",".",FULL,unique=True,script="11_word_book"))

# --- pause menu
out.append(node("PausePanel","Control",".",FULL,unique=True))
out.append(node("PauseDim","ColorRect","PausePanel",dict(FULL,color="Color(0.0196078, 0.0235294, 0.0392157, 0.75)")))
out.append(node("PauseCenter","CenterContainer","PausePanel",FULL))
out.append(node("PauseBox","PanelContainer","PausePanel/PauseCenter",{"layout_mode":"2"}))
out.append(node("PauseList","VBoxContainer","PausePanel/PauseCenter/PauseBox",{"layout_mode":"2","theme_override_constants/separation":"16"}))
out.append(label("PauseTitle","PausePanel/PauseCenter/PauseBox/PauseList","Pauză",64,"TitleLabel",align=1))
out.append(label("PauseSeed","PausePanel/PauseCenter/PauseBox/PauseList","Seed",22,"SecondaryLabel",align=1))
out.append(node("PauseButtons","VBoxContainer","PausePanel/PauseCenter/PauseBox/PauseList",{"layout_mode":"2","theme_override_constants/separation":"12"},unique=True))
out.append(node("ResumeButton","Button","PausePanel/PauseCenter/PauseBox/PauseList/PauseButtons",{"custom_minimum_size":"Vector2(460, 72)","layout_mode":"2","text":'"Resume"'},unique=True))
out.append(node("RuneBookButton","Button","PausePanel/PauseCenter/PauseBox/PauseList/PauseButtons",{"custom_minimum_size":"Vector2(460, 72)","layout_mode":"2","text":'"Runes"',"metadata/tutorial_id":'"btn_rune_book"'},unique=True))
out.append(node("MainMenuButton","Button","PausePanel/PauseCenter/PauseBox/PauseList/PauseButtons",{"custom_minimum_size":"Vector2(460, 72)","layout_mode":"2","text":'"Menu"'},unique=True))
out.append(node("RuneBook","Control",".",FULL,unique=True,script="12_rune_book"))
open('scenes/round.tscn','w').write("\n".join(out))
print("ok")
