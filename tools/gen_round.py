# Generates scenes/round.tscn (the fight screen layout, provisional until Stage 5 step G). Run from the project root:
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
     ("Script","res://scripts/ui/hp_bar.gd","11_hp_bar"),
     ("Script","res://scripts/ui/rune_book.gd","12_rune_book"),
     ("Script","res://scripts/ui/sentence_bar.gd","13_sentence"),("Script","res://scripts/ui/scroll_slot.gd","14_scroll"),
     ("Script","res://scripts/ui/choice_panel.gd","15_choice"),("Script","res://scripts/ui/action_learned.gd","16_action")]
subs=''
out=[f'[gd_scene load_steps={len(ext)+1} format=3]\n']
for t,p,i in ext: out.append(f'[ext_resource type="{t}" path="{p}" id="{i}"]')
out.append("")
out.append(node("Round","Control",None,dict(FULL,layout_mode="3"),script="1_round"))
out.append(node("Backdrop","Control",".",dict(FULL,mouse_filter="2"),unique=True,script="2_backdrop"))
out.append(node("Classroom","Control",".",dict(FULL,mouse_filter="2",visible="false"),unique=True,script="10_classroom"))

# --- left column: info, damage estimate, Power x Resonance, candles, chalk, sort
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

out.append(node("EstimatePanel","PanelContainer",".",tid(rect(40,250,400,180),"estimate")))
out.append(node("EstimateBox","VBoxContainer","EstimatePanel",{"layout_mode":"2","theme_override_constants/separation":"0"}))
out.append(label("EstimateLabel","EstimatePanel/EstimateBox","Daună",24,"SecondaryLabel"))
out.append(label("EstimateValue","EstimatePanel/EstimateBox","0",64,align=0,extra={"theme_override_constants/line_spacing":"-10"}))
out.append(label("EstimateNote","EstimatePanel/EstimateBox","",26,color="Color(1, 0.701961, 0.278431, 1)"))
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
out.append(node("SortRoleButton","Button","SortBox",{"custom_minimum_size":"Vector2(220, 52)","layout_mode":"2","theme_override_font_sizes/font_size":"24","text":'"Rol"'},unique=True))
out.append(node("SortKinButton","Button","SortBox",{"custom_minimum_size":"Vector2(220, 52)","layout_mode":"2","theme_override_font_sizes/font_size":"24","text":'"Neam"'},unique=True))

# --- top center: the monster's card
out.append(node("MonsterCard","PanelContainer",".",tid(rect(560,14,760,232),"monster"),unique=True))
out.append(node("CardRow","HBoxContainer","MonsterCard",{"layout_mode":"2","theme_override_constants/separation":"18"}))
out.append(node("Portrait","Control","MonsterCard/CardRow",{"custom_minimum_size":"Vector2(130, 130)","layout_mode":"2","size_flags_vertical":"4","mouse_filter":"2"},unique=True,script="4_portrait"))
out.append(node("CardText","VBoxContainer","MonsterCard/CardRow",{"layout_mode":"2","size_flags_horizontal":"3","theme_override_constants/separation":"2"}))
out.append(label("MonsterName","MonsterCard/CardRow/CardText","Nume",36,"TitleLabel"))
out.append(node("HpBar","Control","MonsterCard/CardRow/CardText",{"custom_minimum_size":"Vector2(0, 38)","layout_mode":"2","metadata/tutorial_id":'"hp"'},unique=True,script="11_hp_bar"))
out.append(label("MonsterTraits","MonsterCard/CardRow/CardText","",20,"SecondaryLabel"))
out.append(label("MonsterStatus","MonsterCard/CardRow/CardText","",20,color="Color(1, 0.415686, 0.239216, 1)"))
out.append(node("RuleBox","PanelContainer","MonsterCard/CardRow/CardText",{"layout_mode":"2","theme_type_variation":'&"RulePanel"'},unique=True))
out.append(label("RuleText","MonsterCard/CardRow/CardText/RuleBox","regula",18,extra={"autowrap_mode":"3"}))

# --- center: rune circle
out.append(node("RuneCircle","Control",".",tid(rect(740,246,440,440),"circle"),unique=True,script="5_circle"))
out.append(node("CircleText","VBoxContainer","RuneCircle",{"layout_mode":"1","anchors_preset":"8","anchor_left":"0.5","anchor_top":"0.5","anchor_right":"0.5","anchor_bottom":"0.5","offset_left":"-150.0","offset_top":"-120.0","offset_right":"150.0","offset_bottom":"120.0","grow_horizontal":"2","grow_vertical":"2","mouse_filter":"2","alignment":"1","theme_override_constants/separation":"2"}))
out.append(label("SpellName","RuneCircle/CircleText","Alege",40,"TitleLabel",align=1,extra={"autowrap_mode":"3"}))
out.append(label("SpellSecond","RuneCircle/CircleText","",22,"SecondaryLabel",align=1,extra={"autowrap_mode":"3"}))
out.append(label("CircleInfo","RuneCircle/CircleText","",22,"SecondaryLabel",align=1,extra={"autowrap_mode":"3"}))
out.append(label("PreviewValue","RuneCircle/CircleText","",40,align=1))

# --- right: talismans, consumables, the stones seen ahead
out.append(node("Talismans","Control",".",dict(rect(1320,14,580,210),mouse_filter="2"),unique=True,script="6_string"))
out.append(node("Consumables","Control",".",dict(rect(1600,262,290,190),mouse_filter="2",slots="2",show_rope="false"),unique=True,script="6_string"))
out.append(node("PeekPanel","VBoxContainer",".",dict(tid(rect(1400,560,500,120),"peek"),mouse_filter="2"),unique=True))
out.append(label("PeekLabel","PeekPanel","Urmează",22,"SecondaryLabel",align=1))
out.append(node("PeekStones","HBoxContainer","PeekPanel",{"layout_mode":"2","alignment":"1","theme_override_constants/separation":"14"},unique=True))

# --- bottom: hand and actions
out.append(node("Hand","Control",".",tid(rect(310,690,1310,390),"hand"),unique=True,script="7_hand"))
out.append(node("SentenceBar","Control",".",dict(rect(360,690,1200,104),mouse_filter="2"),unique=True,script="13_sentence"))
out.append(node("ScrollSlot","Control",".",rect(1650,690,240,112),unique=True,script="14_scroll"))
out.append(node("Actions","VBoxContainer",".",dict(rect(1640,818,250,222),**{"theme_override_constants/separation":"14","alignment":"2"})))
out.append(node("CastButton","Button","Actions",{"custom_minimum_size":"Vector2(250, 110)","layout_mode":"2","theme_type_variation":'&"CastButton"',"text":'"Rostește"',"metadata/tutorial_id":'"btn_cast"'},unique=True))
out.append(node("SwapButton","Button","Actions",{"custom_minimum_size":"Vector2(250, 64)","layout_mode":"2","text":'"Schimbă"',"metadata/tutorial_id":'"btn_swap"'},unique=True))

# --- overlays
out.append(node("FloatLayer","Control",".",dict(FULL,mouse_filter="2"),unique=True,script="8_float"))
out.append(node("Toast","Label",".",dict(rect(460,722,1000,56),**{"theme_override_font_sizes/font_size":"34","theme_override_colors/font_color":"Color(1, 0.701961, 0.278431, 1)","theme_override_colors/font_outline_color":"Color(0.0196078, 0.0235294, 0.0392157, 1)","theme_override_constants/outline_size":"10","text":'"toast"',"horizontal_alignment":"1"}),unique=True))
out.append(node("ActionLearned","Control",".",dict(FULL,mouse_filter="2"),unique=True,script="16_action"))
out.append(node("ChoicePanel","PanelContainer",".",dict(rect(580,400,760,280),visible="false"),unique=True,script="15_choice"))
out.append(node("SpellReveal",None,".",FULL,unique=True,instance="9_reveal"))
out.append(node("ResultPanel","PanelContainer",".",{"visible":"false","layout_mode":"1","anchors_preset":"8","anchor_left":"0.5","anchor_top":"0.5","anchor_right":"0.5","anchor_bottom":"0.5","offset_left":"-400.0","offset_top":"-210.0","offset_right":"400.0","offset_bottom":"210.0","grow_horizontal":"2","grow_vertical":"2"},unique=True))
out.append(node("ResultBox","VBoxContainer","ResultPanel",{"layout_mode":"2","alignment":"1","theme_override_constants/separation":"16"}))
out.append(label("ResultTitle","ResultPanel/ResultBox","Rezultat",72,"TitleLabel",align=1))
out.append(label("ResultDamage","ResultPanel/ResultBox","daună",34,align=1))
out.append(label("ResultMoney","ResultPanel/ResultBox","",26,color="Color(0.921569, 0.666667, 0.235294, 1)",align=1))
out.append(node("ResultButtons","HBoxContainer","ResultPanel/ResultBox",{"layout_mode":"2","alignment":"1","theme_override_constants/separation":"20"}))
out.append(node("AgainButton","Button","ResultPanel/ResultBox/ResultButtons",{"custom_minimum_size":"Vector2(320, 72)","layout_mode":"2","theme_type_variation":'&"CastButton"',"theme_override_font_sizes/font_size":"32","text":'"Again"'},unique=True))
out.append(node("ResultMenuButton","Button","ResultPanel/ResultBox/ResultButtons",{"custom_minimum_size":"Vector2(220, 72)","layout_mode":"2","text":'"Menu"'},unique=True))

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
