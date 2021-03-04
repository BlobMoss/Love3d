local content = {}

function content.loadModel(path)
    local o = {}
    local file = love.filesystem.lines(path)
    local lines = {}
    local vertices = {}

    --Set table of lines
    for line in file do 
		table.insert(lines, line)
	end

    for _, line in ipairs(lines) do
        --A line starting with v contains vertex coordinates
        if string.sub(line, 1, 1) == "v" then
            --Split values to form a vertex
            local vertexString = split(line, "%S+")
            local vertex = vector3(
                tonumber(vertexString[2]), 
                tonumber(vertexString[3]), 
                tonumber(vertexString[4])
            )
            table.insert(vertices, vertex)
        --A line starting with f shows which vertices form triangles
        elseif string.sub(line, 1, 1) == "f" then
            --Split values to form a face
            local faceString = split(line, "%S+")
            local face = { 
                tonumber(faceString[2]), 
                tonumber(faceString[3]), 
                tonumber(faceString[4]) 
            }
            --Choose vertices from table of gathered data
            local triangle = {
                vertices[face[1]],
                vertices[face[2]],
                vertices[face[3]],
                color = vector3(0.2, 0.3, 0.6)
            }
            
            table.insert(o, triangle)
        end
    end
    return o
end

function split(inputString, seperator)
    local o = {}
    for substring in string.gmatch(inputString, seperator) do
        table.insert(o, substring)
    end
    return o
end

return content