% 加载模型
load('pinecone_detector2.mat');

% 读取图像
image = imread('C:\Users\13729\Desktop\3.png');
image = imresize(image, [512 512]);

% 进行目标检测
[bboxes, scores] = detect(detector, image);
disp(['Number of detected boxes: ', num2str(size(bboxes, 1))]);

% 在图像上画出检测到的bounding box，同时计算并打印中心坐标
for i = 1:size(bboxes, 1)
    if scores(i) > 0.9
        image = insertShape(image, 'Rectangle', bboxes(i, :), 'LineWidth', 2);
        
        % 计算并打印中心坐标
        centerX = bboxes(i, 1) + bboxes(i, 3) / 2;
        centerY = bboxes(i, 2) + bboxes(i, 4) / 2;
        disp(['Center of box ', num2str(i), ': (', num2str(centerX), ', ', num2str(centerY), ')']);
    end
end

% 显示图像
imshow(image);

% 保存图像
%imwrite(image, 'detected_pinecone.jpg');
