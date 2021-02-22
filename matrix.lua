local matrix = {}

function matrix.multiply(mtx1, mtx2)
	local mtx = {}

	for i = 1, #mtx1
    do
		mtx[i] = {}
		for j = 1, #mtx2[1] 
        do
			local newValue = mtx1[i][1] * mtx2[1][j]
			for n = 2, #mtx1[1]
            do
				newValue = newValue + mtx1[i][n] * mtx2[n][j]
			end
			mtx[i][j] = newValue
		end
	end

	return mtx
end

function matrix.rotationX(angle)
	mtx = {
		{1, 0, 0},
		{0, math.cos(angle), -math.sin(angle), 0},
		{0, math.sin(angle), math.cos(angle)}
	}
	return mtx
end

function matrix.rotationY(angle)
	mtx = {
		{math.cos(angle), 0, math.sin(angle)},
		{0, 1, 0},
		{-math.sin(angle), 0, math.cos(angle)}
	}
	return mtx
end

function matrix.rotationZ(angle)
	mtx = {
		{math.cos(angle), -math.sin(angle), 0},
		{math.sin(angle), math.cos(angle), 0},
		{0, 0, 1}
	}
	return mtx
end

return matrix