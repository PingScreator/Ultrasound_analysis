%Calculate the offset of pelvic floor muscle
clc;%清理命令行窗口
clear all;%清理工作區
close all;

% Load the two images
% path = '.\PFM_offset';
% imgL = imread('PSpelvic_L.jpg');%pelvic floor muscle is loose
% imgT = imread('PSpelvic_T.jpg');%pelvic floor muscle is tight
imgL = imread('PSpelvic_L.bmp');%pelvic floor muscle is loose
imgT = imread('PSpelvic_T.bmp');%pelvic floor muscle is tight

pfm_offset = figure(1);
% Find the middle line
[curve, curve_threshold] = edge(imgL, 'Canny');
[y, x] = find(curve);
midpoint = [mean(x), mean(y)];

% Draw the middle line
imshow(imgL);hold on;
% line([midpoint(1), midpoint(1)], [1, size(imgL,1)], 'Color', 'red');

% Overlay the two images
img_overlay = imfuse(imgL, imgT, 'falsecolor', 'Scaling', 'joint');
imshow(img_overlay);hold on;
% line([midpoint(1), midpoint(1)], [1, size(imgL,1)], 'Color', 'red');

% Mark the target organ position in both images
[x1, y1] = ginput(1);
l=plot(x1, y1,'r.');hold on;
[x2, y2] = ginput(1);%1
t=plot(x2, y2,'r.');
line([x1, x2], [y1, y2], 'Color', 'r');

% Mark the physical position in images(vernier scale)
% 改成固定值:47像素
% [x3, y3] = ginput(1);
% o1 = plot(x3, y3,'b.');hold on;
% [x4, y4] = ginput(1);%1
% o2 = plot(x4, y4,'b.');
% line([x3, x4], [y3, y4], 'Color', 'b');hold off;

% Calculate the offset:WAY1手動找位置
offset = abs([x2 - x1, y2 - y1]);                                          %求得偏移量(像素距離)，顯示水平及垂直像素
% vernier_scale = abs([x4 - x3, y4 - y3]);                                 %計算游標尺大小,，顯示水平及垂直像素。1:像素
vs = 47;
% vs = ((x4 - x3).^2 + (y4 - y3).^2)^0.5;
PFM =sqrt((x2 - x1).^2 + (y2 - y1).^2);                                    %計算偏移量(像素距離)(畢氏定理)
% Transfer : dpi->inch->cm: vertical resolution = horizontal resolution = 96dpi = 1/96inch=(1/96)*2.54
PFM_displacement = (PFM/96)*2.54;                                          %(用像素去轉換)求得實際位移量數值cm

ratio = (PFM/vs);                                                          %(用游標尺比例算)求得實際位移量數值cm

fprintf('offset偏移量為 %.2f 像素\n', offset);
% fprintf('游標尺為 %.2f 像素\n', vernier_scale);
fprintf('PFM偏移量為 %.2f 像素\n', PFM);
% fprintf('游標尺為 %.2f 像素\n',vs);
fprintf('PFM位移量(用像素去轉換)為 %.2f (cm)\n',PFM_displacement);
fprintf('PFM位移量(用游標尺比例算)為 %.2f (cm)\n',ratio);

% Store the offset in a table
% offset_table = table(offset, vernier_scale, PFM, PFM_displacement,vs,ratio);
offset_table = table(offset, PFM, PFM_displacement,vs,ratio);

% 在圖片上加入文字
text_str = sprintf('Offset: %.1f cm', ratio);
position = [620, 550]; % 文字位置
img = insertText(img_overlay, position, text_str, 'FontSize', 20, 'BoxColor', 'white', 'BoxOpacity', 0.7);

% % Save the processing image
imwrite(img,'PFM_offset_2.png');
% saveas(pfm_offset,'PFM_offset_2.png');