-- load common SDL input/video library
local SDL = require("ffi/SDL2_0")
local BB = require("ffi/blitbuffer")
local util = require("ffi/util")

local framebuffer = {}

function framebuffer:init()
    if not self.dummy then
		SDL.open()
		-- we present this buffer to the outside
		self.bb = BB.new(SDL.w, SDL.h, BB.TYPE_BBRGB32)
	else
		self.bb = BB.new(600, 800)
    end

    self.bb:fill(BB.COLOR_WHITE)
	self:refreshFull()

    framebuffer.parent.init(self)
end

local function render(bb)
	SDL.SDL.SDL_UpdateTexture(SDL.texture, nil, bb.data, bb.pitch)
	SDL.SDL.SDL_RenderClear(SDL.renderer)
	SDL.SDL.SDL_RenderCopy(SDL.renderer, SDL.texture, nil, nil)
	SDL.SDL.SDL_RenderPresent(SDL.renderer)
end

function framebuffer:refreshFullImp()
	if self.dummy then return end

    local bb = self.full_bb or self.bb

    if not (x and y and w and h) then
        x = 0
        y = 0
        w = bb:getWidth()
        h = bb:getHeight()
    end

    self.debug("refresh on physical rectangle", x, y, w, h)

    local flash = os.getenv("EMULATE_READER_FLASH")
    if flash then
        bb:invertRect(x, y, w, h)
        render(bb)
        util.usleep(tonumber(flash)*1000)
        bb:invertRect(x, y, w, h)
    end
    render(bb)
end

function framebuffer:close()
    SDL.SDL.SDL_Quit()
end

return require("ffi/framebuffer"):extend(framebuffer)
