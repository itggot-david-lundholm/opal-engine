require 'canvas'
window = Canvas.init

window.mouse_move do |x, y| 
    window.fill_circle(x,y, 15, "green")
end