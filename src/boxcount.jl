using Images, FileIO

function box_count(contours, box_length)
    count = Set()
    for contour in contours
        for coord in contour
            x, y = Tuple(coord)
            push!(count, [ceil(Int64, x/box_length) - 1, ceil(Int64, y/box_length) - 1])
        end
    end

    return count
end

function draw_box(image, color, boxes, box_length)
    width, height = size(image)
    for box in boxes
        x = box[1] * box_length
        y = box[2] * box_length

        for i=x+1:min(width, x+box_length)
            for j=y+1:min(height, y+box_length)
                image[CartesianIndex(i, j)] = color
            end
        end
    end
end