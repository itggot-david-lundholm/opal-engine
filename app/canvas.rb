require 'config'
require 'input'

class Canvas
    attr_reader :canvas, :context, :width,:height

    
    def initialize canvas_id, double_buffering=false
        @double_buffering = double_buffering
        @canvas_element = Element.find("#"+canvas_id)
        @canvas = `document.getElementById(#{canvas_id})`
        @buffer = `document.createElement('canvas')`
        `#{@buffer}.width = #{@canvas}.width`
        `#{@buffer}.height = #{@canvas}.height`
        @buffer_context = `#{@buffer}.getContext("2d")`        
        @context = `#{@canvas}.getContext("2d")`        
        @target_context = double_buffering ? @buffer_context : @context        
        @width = `#{@canvas}.width`
        @height = `#{@canvas}.height`
        `#{@canvas}.focus()`
        @num_images = 0
        @num_loaded_images = 0
    end

    def self.init
        return Canvas.new Config::CanvasId
    end 



    ############
    # Resources
    ############
    def load_image file_name
        @num_images += 1
        image = Element.new :img
        image.attr("src", "img/foo.png")
        
        image.on :load do
            @num_loaded_images += 1
            `#{@context}.drawImage(#{image.get(0)}, 0,0)`
        end

        return image
    end



    ##########
    # Events
    ##########
    def key_event event_type
        Document.on event_type do |event|            
            yield(event.key_code)
        end
    end

    def key_down &block
        key_event :keydown, &block
    end

    def key_up &block
        key_event :keyup, &block      
    end

    def mouse_event event_type        
        @canvas_element.on event_type do |event|
            mouse_x = event.page_x - `#{event.target}[0].offsetLeft`
            mouse_y = event.page_y - `#{event.target}[0].offsetTop`
            yield(mouse_x, mouse_y)
        end
    end

    def mouse_down &block
        mouse_event :mousedown, &block
    end

    def mouse_up &block
        mouse_event :mouseup, &block

    end

    def mouse_click &block
        mouse_event :click, &block
    end

    def mouse_move &block
        mouse_event :mousemove, &block
    end

    ######################
    # Graphics and Shapes
    ######################
    def set_color color
        `#{@target_context}.fillStyle=#{color}`
    end

    def fill_rectangle start_x, start_y, width, height, color
        set_color color
        `#{@target_context}.fillRect(#{start_x},#{start_y},#{width},#{height})`
    end

    def draw_rectangle start_x, start_y, width, height, color
         `#{@target_context}.strokeStyle = #{color}`
        end_x = start_x + width
        end_y = start_y + height
        `#{@target_context}.beginPath()`
        `#{@target_context}.moveTo(#{start_x},#{start_y})`
        `#{@target_context}.lineTo(#{end_x},#{start_y})`
        `#{@target_context}.lineTo(#{end_x},#{end_y})`
        `#{@target_context}.lineTo(#{start_x},#{end_y})`
        `#{@target_context}.lineTo(#{start_x},#{start_y})`
        `#{@target_context}.stroke()`
    end

    def fill_circle origin_x, origin_y, radius, color
        set_color color
        draw_circle(origin_x,origin_y,radius,color)
        `#{@target_context}.fill()`
    end

    def draw_circle origin_x, origin_y, radius, color
         `#{@target_context}.strokeStyle = #{color}`         
         `#{@target_context}.beginPath()`
         `#{@target_context}.arc(#{origin_x},#{origin_y},#{radius},#{0},Math.PI*2)`
         `#{@target_context}.closePath()`
         `#{@target_context}.stroke()`         
    end

    def draw_image image
        `#{@target_context}.drawImage(#{image.get(0)}, 0,0)`
    end

    def draw_line start_x, start_y, end_x, end_y, color
        `#{@target_context}.strokeStyle = #{color}`
        `#{@target_context}.beginPath()`
        `#{@target_context}.moveTo(#{start_x},#{start_y})`
        `#{@target_context}.lineTo(#{end_x},#{end_y})`
        `#{@target_context}.stroke()`
    end

    def draw_text text, x, y, color="white", size="20px", font="Arial"
        set_color color
        `#{@target_context}.font = "#{size} #{font}"`
        `#{@target_context}.fillText(#{text},#{x},#{y})`
    end

    def set_pixel x,y,color
        fill_rectangle x,y,1,1,color
    end

    def clear
        fill_rectangle 0,0, width,height, "black"        
        #`#{@context}.clearRect(0, 0, #{width}, #{height});`
    end    

    ###########
    # Engine
    ###########
    def render        
        `#{@target_context}.drawImage(#{@buffer}, 0,0)`
    end

    def loop interval
        `setInterval(function() {#{yield}}, #{interval})`
    end

end

def log message
    `console.log(#{message})` 
end