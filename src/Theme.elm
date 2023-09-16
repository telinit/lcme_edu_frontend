module Theme exposing (..)


type alias CSSColor =
    String


type alias ColorsBGFG =
    ( CSSColor, CSSColor )


type alias Colors =
    { marks :
        { excellent : ColorsBGFG
        , good : ColorsBGFG
        , average : ColorsBGFG
        , bad : ColorsBGFG
        , neutral : ColorsBGFG
        , selected : ColorsBGFG
        , empty : ColorsBGFG
        }
    , activities :
        { general : ColorsBGFG
        , final : ColorsBGFG
        , task : ColorsBGFG
        , mean : ColorsBGFG
        , empty : ColorsBGFG
        }
    , ui :
        { primary : CSSColor
        , link : CSSColor
        }
    }


type alias Fonts =
    {}


type alias Theme =
    { colors : Colors, fonts : Fonts }


default : Theme
default =
    { colors =
        { marks =
            { excellent = ( "#76D7C4", "#0e6756" )
            , good = ( "#7DCEA0", "#145931" )
            , average = ( "#F7DC6F", "rgb(119 97 5)" )
            , bad = ( "#D98880", "#922B21" )
            , neutral = ( "#BFC9CA", "#5c5e60" )
            , selected = ( "#7FB3D5", "#1F618D" )
            , empty = ( "#FFF", "#5c5e60" )
            }
        , activities =
            { general = ( "#EEF6FFFF", "#B6C6D5FF" )
            , final = ( "#FFEFE2FF", "#D9C6C1FF" )
            , task = ( "hsl(266, 100%, 97%)", "hsl(266, 27%, 77%)" )
            , mean = ( "rgb(246, 246, 246)", "#000" )
            , empty = ( "#FFF", "#000" )
            }
        , ui =
            { primary = "rgb(65, 131, 196)"
            , link = "#4183C4"
            }
        }
    , fonts = {}
    }
