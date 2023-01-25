using Images, FileIO
using ImageMorphology, ImageBinarization, ImageEdgeDetection, ImageSegmentation
using ImageEdgeDetection: Percentile
using IndirectArrays
using Plots
using Polynomials

include("./contourdetection.jl")
include("./boxcount.jl")

# load images
img = load("src/ff_1.png")

# convert to grayscale
imgg = Gray.(img)
img_gray = copy(imgg)
img_contour = RGB.(imgg)

# edge detection algorithms
alg_canny = Canny(spatial_scale=5, high=Percentile(40), low=Percentile(20))

img_edges_canny = detect_edges(imgg, alg_canny)

# threshold
imgg = imgg .> 0.58

#= watershed
imgg_transform = feature_transform(imgg)
imgg_dist = 1 .- distance_transform(imgg_transform)
dist_trans = imgg_dist .< 1
markers = label_components(dist_trans)
segments = watershed(imgg_dist, markers)
labels = labels_map(segments)
colored_labels = IndirectArray(labels, distinguishable_colors(maximum(labels)))
=#

# calling find_contours
cnts = find_contours(imgg)

# finally, draw the detected contours
draw_contours(img_contour, RGB(1,1,0), cnts)

contour = fill(RGB{N0f8}(1), size(img_contour))
box_fill = copy(contour)

draw_contours(contour, RGB(0,0,0), cnts)
draw_box(box_fill, RGB(0,200/255,0), box_count(contour, cnts, 5), 5)
draw_contours(box_fill, RGB(0, 0, 0), cnts)

# box-counting dimension
sizes = 20:-1:1
count = []

for size in sizes
    push!(count, length(box_count(contour, cnts, size)))
end

base_size = 20
x = log.(sizes.^-1 .*base_size)
y = log.(count)

dimension_plot = scatter(x, y, title="Minkowski Dimension (base: $(base_size), range: [$(sizes[1]), $(sizes[end])])", label="Data", xlabel="ln(scale_factor)", ylabel="ln(box_count)")
linefit = fit(x, y, 1)
quadfit = fit(x, y, 2)
plot!(linefit, x[1], x[end], label="Linear Regression")
plot!(quadfit, x[1], x[end], label="Quadratic Regression")
savefig(dimension_plot, "src/dimension_plot.png")

save("src/img_results.png", [img RGB.(img_gray) RGB.(imgg) img_contour contour box_fill])