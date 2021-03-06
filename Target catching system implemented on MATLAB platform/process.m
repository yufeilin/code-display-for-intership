clear
location = '/Users/yinz/Desktop/digital_image_processing_final/frames/';
img_size = [225, 400, 30];
count = img_size(3);
T = 0.001;
T2 = 0.05;
area_T = 50;
hsv_frames = zeros([img_size(1:2) 3 img_size(3)]);

% step1: read image frames
frames = zeros(img_size);
for i = 1:count
    origin_img = imread([location num2str(i) '.tiff']);
    rgb_img = origin_img(:,:,1:3);
    rgb_img = double(rgb_img);
    hsv_frames(:,:,:,i) = rgb2hsv(rgb_img);
    
    % turn RGB images to grey image
    grey_img = (rgb_img(:,:,1) + rgb_img(:,:,2) + rgb_img(:,:,3)) / 3 / 255;
    
    % append grey frames
    frames(:,:,i) = grey_img;
end

% step2: calculate the common background
bg = zeros(img_size(1:2));
for i = 2:count
    prev_frame = frames(:,:,i-1);
    frame = frames(:,:,i);
    for y = 1:img_size(1)
        for x = 1:img_size(2)
            if abs(prev_frame(y,x) - frame(y,x)) < T
                if bg(y,x) == 0
                    bg(y,x) = frame(y,x);
                else
                    bg(y,x) = (bg(y,x)+frame(y,x))/2;
                end
            end
        end
    end
end

% step2.5: calculate the common color to detect shadow
hsv_bg = zeros([img_size(1:2) 3]);
for i = 1:count
    for y = 1:img_size(1)
        for x = 1:img_size(2)
            x,y
            hsv_values = reshape(hsv_frames(y,x,:,:), 3,30)';
            [unique_value,~,unique_idx] = unique(hsv_values,'rows');
            mode_idx = mode(unique_idx);
            hsv_bg(y,x,:) = unique_value(mode_idx,:);
        end
    end
end

% step3: calculate the moving obj filter
filter = zeros(img_size);
for i = 1:count
    frame = frames(:,:,i);
    for y = 1:img_size(1)
        for x = 1:img_size(2)
            if abs(frame(y,x) - bg(y,x)) > T2
                filter(y,x,i) = 1;
            else
                filter(y,x,i) = 0;
            end
        end
    end
end

% step4: post-processing the filter
for i = 1:count
    % open and close
    filter(:,:,i) = imopen(filter(:,:,i), strel('disk',1));
    filter(:,:,i) = imclose(filter(:,:,i), strel('square',10));
    
    % remove shadow area
    
end



% step5: use filter to get moving obj frames
figure(1)
for i = 1:count
    bw_img = im2bw(filter(:,:,i), 0);
    img_reg = regionprops(bw_img,  'area', 'boundingbox');  
    areas = [img_reg.Area];  
    rects = cat(1,  img_reg.BoundingBox);  
    % show all the largest connected region  
    imshow(frames(:,:,i));  
    for k = 1:size(rects, 1)
        if areas(k) > area_T
            rectangle('position', rects(k, :), 'EdgeColor', 'r');  
        end
    end
    pause(0.1);
end
