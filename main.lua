function love.load()
    courbd = love.graphics.newFont("courbd.ttf", 8)
    love.graphics.setFont(courbd)
	love.graphics.setColor(212, 157, 19)
	
	musicTrack = love.audio.newSource("still_alive.mp3", "stream")
	pages = require("data.lyrics")
	credits = require("data.credits")
	asciiart = require("data.asciiart")
	
	-- State
	time = 0
	blink = false
	musicPlayed = false
	nPage = 1
    lLine = 1
	nLyric = 1
    lChar = 0
	
	cLine = 200
	cChar = 13

	loadLyric()
	quote=""
end

function loadLyric()
	line = pages[nPage][lLine]
	
	length = math.max(1, #line.text[nLyric])
	interval = line.duration[nLyric] / length
	
	endTime = time + line.duration[nLyric]
	pauseLeft = line.pause[nLyric]
	
	
end

function nextLyric()

	if nLyric < #line.text then
		nLyric = nLyric + 1
		lChar = 0
		
	else
		lLine = lLine + 1
		nLyric = 1
		lChar = 0
		
	end
	
	if lLine > #pages[nPage] then
		nPage = nPage + 1
        lLine = 1
	end
	
	if nPage <= #pages then
        loadLyric()
    end
end

function drawBorder()
	for i = 1, 30 do
		love.graphics.print('|', 3, 11 + (i - 0.5) * 14.2 )
		love.graphics.print('|', 238, 11 + (i - 0.5) * 14.2 )
	end
	
	for i = 1, 49 do
		love.graphics.print('-', -3 + (i * 4.82), 4 )
		love.graphics.print('-', -3 + (i * 4.82), 451 )
	end
	
	for i = 1, 16 do
		love.graphics.print('|', 243, 11 + (i - 0.5) * 14.2 )
		love.graphics.print('|', 489, 11 + (i - 0.5) * 14.2 )
	end
	
	for i = 1, 49 do
		love.graphics.print('-', 243 + (i * 4.82), 4 )
		love.graphics.print('-', 243 + (i * 4.82), 240 )
	end
end

function drawASCII(artType)
	for y = 1, 20 do
		for x = 1, 40 do
			love.graphics.print(string.sub(asciiart[artType][y], x, x), 262 + (x * 4.82), 232 + y * 12 )
		end
	end
end

function love.update(dt)
    time = time + dt
	blink = math.floor(time / 0.3) % 2 == 0

	if time >= endTime then
		if pauseLeft > 0 then
            pauseLeft = pauseLeft - dt
			if pauseLeft <= 0 then
                nextLyric()
            end
		else
			nextLyric()
		end
	end
	
	if lChar < #line.text[nLyric] then
        lChar = math.min(#line.text[nLyric], lChar + dt / interval)
    end
end

function love.draw()
	local x, y = 6, 5
	
	-- Start music
    if not musicPlayed and lLine == 5 then
        musicTrack:play()
        musicPlayed = true
    end
	
	-- Draw lyrics
    if nPage <= #pages then
        drawBorder()
		
		-- Draw finished lyrics
		for i = 1, lLine - 1 do
			currentText = ""
			for j = 1, #pages[nPage][i].text do
				currentText = currentText..pages[nPage][i].text[j]
			end
			
			love.graphics.print(currentText, x, y + 14.5*i - 7.25)
        end
		
		-- Draw typewriter lyrics
		partial = ""
		for i = 1, nLyric - 1 do
			partial = partial .. pages[nPage][lLine].text[i]
		end
		partial = partial .. string.sub(pages[nPage][lLine].text[nLyric], 1, math.floor(lChar))
		
		if blink == true then 
			partial = partial .. "_"
		end
			love.graphics.print(partial, x, y + 14.5*lLine - 7.25)
	end
	
	-- Draw finished credits
	if cLine < 16 then
		for i = 1, cLine - 1 do
			currentText = credits[i].text
			love.graphics.print(currentText, 252, 233.5 + 14.3*(i-cLine) - 7.15)
		end
	else
		for i = cLine-15, cLine - 1 do
			currentText = credits[i].text
			love.graphics.print(currentText, 252, 233.5 + 14.3*(i-cLine) - 7.15)
		end
	end
	
	-- Draw typewriter credits
	currentText = credits[cLine].text
	partial = string.sub(currentText, 1, math.floor(cChar))
	if blink == false then
		partial = partial .. "_"
	end
	love.graphics.print(partial, 252, 226.5)
	
	-- Draw ASCII art
	drawASCII(1)
	
	-- Testing
	
end