Races = Array.new
RaceAppearanceNames = Array.new
RaceFaceImage = Array.new
RaceFaceIndex = Array.new
RaceChara = Array.new
RaceIndex = Array.new
GenderVar = Array.new
ClassList = Array.new
#############CONFIG######################
#Here list all the names of all races in the game
# Example:
# Races = ["Human","Elf","Dwarf"]
# Creates three races, called Human, Elf and Dwarf
Races = ["Human","Elf","Dwarf"]
#Which race the player chooses will be stored in a variable, which is defined
#below. This can be used later create effects that only affect, say, Dwarves, 
#such as giving them the ability to use heavy armour, regardless of class.
#This can be acheived by having an event check that variable, then run actions 
#accordingly
RaceVariable = 25

#Additionally a variable can store information depending on the appearance of the
#character. This can be used so that events can check information related to the 
#appearance, such as gender.
AppearanceVariable = 26
#The default is to store the Race in variable 25. By default this will mean that 
#if the player is human that varible will be 1, 2 if an elf, and 3 if a dwarf.
#
#Then for each race create a module for showing the Appearance(s)
#Example:
#RaceAppearanceNames << ["Female","Male"]
#RaceFaceImage << ["Actor3.png","Actor3.png"]
#RaceFaceIndex << [6,5]
#RaceChara << ["Actor3.png","Actor3.png"]
#RaceIndex << [6,5]
#GenderVar << [1,0]
#ClassList << [6,-1,2,-4]
#
#The first row shows that the first race we typed in at the start has two
#different Appearances. One called Female, one called Male.
#
#The second row shows the File name for that appearances face. So both Male and
#Female humans use Actor1.png
#The third row shows which face in the file to use, as each image has 8 faces,
#so female humans use the first face in the Actor1.png Image, and Males use the 
#second image.
#
#The fourth and fifth line work like the Faces, appart from for defining the 
#Character image that is seen walking around the screen. In the example above
#both Male and Female humans have characters to match their faces.
#
#The 6th line is used to set the Appearance variable. In this case having the 
#"Male" apperance will set the Appearance variable (Default 26) to 0, while the
#"Female" will set it to 1. This way you can have NPCs react depending on Gender
#
#Finally the seventh line lists all classes, in order, that that class can take.
#Listing a class as negitive (I.e. -3) will mean that it is listed, but you cannot 
#select it. This can be used to clearly show what class can and cannot take certain
#classes, while still being able to hide information from the player.
#
#For each race you defined at the start, copy paste these six lines, and customize
#as you wish.

#Race 1:
RaceAppearanceNames << ["Ginger","Green","Purple","Wings"]
RaceFaceImage << ["Actor1.png","Actor2.png","Actor3.png","Actor4.png"]
RaceFaceIndex << [1,2,3,4]
RaceChara << ["Actor1.png","Actor2.png","Actor3.png","Actor4.png"]
RaceIndex << [1,2,3,4]
GenderVar << [0,1,0,1]
ClassList << [3,1,2,5]
#Race 2:
RaceAppearanceNames << ["Female","Male"]
RaceFaceImage << ["Actor3.png","Actor3.png"]
RaceFaceIndex << [6,5]
RaceChara << ["Actor3.png","Actor3.png"]
RaceIndex << [6,5]
GenderVar << [1,0]
ClassList << [6,-1,2,-4]
#Race 3:
RaceAppearanceNames << ["Male"]
RaceFaceImage << ["Actor3.png"]
RaceFaceIndex << [7]
RaceChara << ["Actor3.png"]
RaceIndex << [7]
GenderVar << [0]
ClassList << [5,3,2,-4,1-6]

############END CONFIG############################

#==============================================================================
# ** Scene_Status
#------------------------------------------------------------------------------
#  This class performs the status screen processing.
#==============================================================================

class Scene_CharacterCreation < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_status_window
    @stage = 1
    @finished = false
    @class_window = Window_Create.new(@actor)
    @race_window = Window_Race.new(@actor)
    @look_window = Window_Appearance.new(@actor,1)
    @status_window.width = Graphics.width
    @class_window.index =  (@actor.class.id - 1)
    @class_window.width = Graphics.width / 3
    @class_window.active = false
    @class_window.visible = false
    @class_window.id = 0
    @look_window.active = false
    @look_window.visible = false
    @race_window.width = Graphics.width / 3
    @look_window.width = Graphics.width / 3
    @class_window.set_handler(:class,method(:changeActorClass))
    @class_window.set_handler(:cancel,   method(:back))
    @look_window.set_handler(:cancel,   method(:back))
    @look_window.set_handler(:look,   method(:finish))
    @race_window.set_handler(:race,method(:changeActorRace))
  end
 alias oldupdate update
  def update()
    oldupdate()
    if @finished == true
      return_scene
    end
    raceID = @race_window.index
    appID = @look_window.index
    appIndex = RaceIndex
    @actor.set_graphic(RaceChara[raceID][appID],RaceIndex[raceID][appID]-1 ,RaceFaceImage[raceID][appID],RaceFaceIndex[raceID][appID]-1) 
    #@actor.set_graphic("Animal.png" ,3,RaceFaceImage[raceID][appID],RaceFaceIndex[raceID][appID]-1)     
    $game_player.refresh
    classID = ClassList[raceID][@class_window.index]
    @actor.change_class(classID)
    @actor.hp = @actor.mhp
    @actor.mp = @actor.mmp
    @actor.init_exp
    @actor.init_skills
    @status_window.refresh
  end
  def finish()
    raceID = @race_window.index
    $game_variables[AppearanceVariable] = GenderVar[raceID][@look_window.index]
    @finished = true
  end
  def back()
    @class_window.active = false
    @race_window.active = false    
    @look_window.active = false
    if @stage == 2
      @look_window.index = 0
      @class_window.index = 0
      @race_window.active = true 
      @stage = 1
    elsif @stage == 3
      @stage = 2
      @class_window.active = true  
    end
  end
  
  def changeActorClass()
    classID = @class_window.index
    @stage = 3
    @look_window.active = true
    @look_window.visible = true
    @status_window.refresh
  end
  
  def changeActorRace()
    raceID = @race_window.index
    @actor.set_graphic(RaceFaceImage[raceID][0],RaceFaceIndex[raceID][0],RaceFaceImage[raceID][0],RaceFaceIndex[raceID][0]-1)
    @status_window.refresh
    @stage = 2
    @class_window.activate
    @class_window.visible = true
    @look_window.id=raceID
    @class_window.id=raceID
    @look_window.index = 0
    $game_variables[RaceVariable] = raceID +1
  end
  
  def create_status_window
    y = 0
    @status_window = Window_SkillStatus.new(0,0)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
end

#==============================================================================
# ** Window_Status
#------------------------------------------------------------------------------
#  This window displays full status specs on the status screen.
#==============================================================================

class Window_Create < Window_Command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(Graphics.width / 3, fitting_height(4))
    self.height = Graphics.height - fitting_height(4)
#    create_help_window
    @actor = actor
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    for i in ClassList[@id.to_i]
      if(i<0)
        add_command($data_classes[i].name, :class,false)
      else
        add_command($data_classes[i].name, :class,true)
      end
    end
  end
  #------------------------------------------------------------------------
  def id=(id)
    @id = id
    refresh
  end
end

############################################################
#
#
# RACE MEANU
#####
class Window_Race < Window_Command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, fitting_height(4))
    self.height = Graphics.height - fitting_height(4)
#    create_help_window
    @actor = actor
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    count = 0
    for i in Races
      add_command(i, :race)
    end
  end
end




class Window_Appearance < Window_Command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor,id)
    super(Graphics.width / 1.5, fitting_height(4))
    self.height = Graphics.height - fitting_height(4)
#    create_help_window
    @actor = actor
    @id = id
    #item_height = 36
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
   # self.item_height = 36
  end
  
  def id=(id)
    @id = id
    refresh
#    self.item_height = 36
    count = 0
    i_id = @id.to_i
    lookArray = RaceAppearanceNames#[@id]
    for i in (0...(lookArray[i_id].length))
      #add_command("   "+lookArray[i_id][i], :look)
      #draw_item(i,RaceChara[i_id][i],RaceIndex[i_id][i])
      draw_character(RaceChara[i_id][i], RaceIndex[i_id][i]-1,16,36*(i+1)-2)
    end
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  alias oldCommand make_command_list
  def make_command_list
    oldCommand
    count = 0
    i_id = @id.to_i
    lookArray = RaceAppearanceNames#[@id]
    for i in (0...(lookArray[i_id].length))
      add_command("   "+lookArray[i_id][i], :look)
      #draw_item(i,RaceChara[i_id][i],RaceIndex[i_id][i])
      #draw_character(RaceChara[i_id][i], RaceIndex[i_id][i],16,36*(i+1)-2)
    end
    #draw_character(RaceChara[i_id][i], RaceIndex[i_id][i], 0, 0)
  end
  
  def draw_item(index,chara="Actor1.png",chaIndex = 1)
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
    #draw_character(chara,chaIndex,16,36*(index+1)-2)
  end
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = 36#item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * 36#item_height
    rect
  end
  def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * 36)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end
  end
    def contents_height
    [super - super % 36, row_max * 36].max
  end
   def update_padding_bottom
    surplus = (height - standard_padding * 2) % 36
    self.padding_bottom = padding + surplus
  end
  def top_row
    oy / 36
  end
   def page_row_max
    (height - padding - padding_bottom) / 36
  end
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * 36
  end
end