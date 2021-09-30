module Cronic
  enum Guess
    Middle
    End
    Begin
  end

  enum Direction
    Backward = -1
    Forward  =  1
  end

  enum PointerDir
    Past   = -1
    None   =  0
    Future =  1

    def to_dir
      return Direction::Forward if self == Future
      return Direction::Forward if self == None
      Direction::Backward
    end
  end

  enum DateEndian
    MonthDay # aka :middle from chronic
    DayMonth # aka :little from chronic
  end
end
