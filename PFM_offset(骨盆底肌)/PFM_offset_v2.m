%Calculate the offset of pelvic floor muscle---------version2
%add the more image processing:  銳化(Edge crispening) & 二值化(Binarization)
clc;%清理命令行窗口
clear all;%清理工作區
close all;

% Load the two images
% path = '.\PFM_offset';
% imgL = imread('PSpelvic_L.jpg');%pelvic floor muscle is loose%
% imgT = imread('PSpelvic_T.jpg');%pelvic floor muscle is tight
imgL = imread('xc.bmp');%pelvic floor muscle is loose
imgT = imread('xc_t.bmp');%pelvic floor muscle is tight

%search the information about imgL & imgT
% 獲取圖像信息
info = imfinfo('LXin.bmp');
info2 = imfinfo('LXin_t.bmp');
% 輸出圖像信息
fprintf('imgL圖像大小： %d x %d\n', info.Width, info.Height);               %可得到imgL影像pixels
fprintf('imgL每個像素的位深度：%d\n', info.BitDepth);
fprintf('imgL顏色映射信息：%s\n', info.ColorType);
fprintf('--------------------------------------\n');
fprintf('imgT圖像大小： %d x %d\n', info2.Width, info.Height);              %可得到imgT影像pixels
fprintf('imgT每個像素的位深度：%d\n', info2.BitDepth);
fprintf('imgT顏色映射信息：%s\n', info2.ColorType);
fprintf('--------------------------------------\n');
%-----------------------------------------------------------------------------%
pfm_offset_o = figure(1);
%process the image
%(1)  imsharpen()函數對圖像進行銳化
imgL_sharpened = imsharpen(imgL);
subplot(2,2,1);
imshow(imgL_sharpened);
imgT_sharpened = imsharpen(imgL);
subplot(2,2,2);
imshow(imgT_sharpened);
%(2)  im2bw()函數對圖像進行二值化
threshold_L = graythresh(imgL);
imgL_bw = im2bw(imgL, threshold_L);
subplot(2,2,3);
imshow(imgL_bw);
threshold_T = graythresh(imgT);
imgT_bw = im2bw(imgT, threshold_T);
subplot(2,2,4);
imshow(imgT_bw);

pfm_offset = figure(2);
% Find the middle line
[curve, curve_threshold] = edge(imgL, 'Canny');
[y, x] = find(curve);
midpoint = [mean(x), mean(y)];
% Draw the middle line
imshow(imgL);hold on;
% line([midpoint(1), midpoint(1)], [1, size(imgL,1)], 'Color', 'red');     % line put here will be cover

% Overlay the two images
img_overlay = imfuse(imgL_bw, imgT_bw, 'falsecolor', 'Scaling', 'joint');
imshow(img_overlay);
% line([midpoint(1), midpoint(1)], [1, size(imgL,1)], 'Color', 'red');

% Mark the target organ position in both images
[x1, y1] = ginput(1);
l=plot(x1, y1,'r.');
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
PFM_displacement = (PFM/96)*2.54;                                          %.jpg檔用的計算(用像素去轉換)求得實際位移量數值cm

ratio = (PFM/vs);                                                          %(用游標尺比例算)求得實際位移量數值cm
% 在圖片上加入文字
t = text(620, 550, sprintf('Offset: %.2f cm', ratio), 'Color', 'white', 'FontSize', 14);hold off;%'BoxOpacity', 0.7

%Command Window display----------------------------------------------------
fprintf('offset偏移量為 %.2f 像素\n', offset);
% fprintf('游標尺為 %.2f 像素\n', vernier_scale);
fprintf('PFM偏移量為 %.2f 像素\n', PFM);
% fprintf('游標尺為 %.2f 像素\n',vs);
fprintf('PFM位移量(jpg檔用固定像素去轉換)為 %.2f (cm)\n',PFM_displacement);  % #檔案為.bmp則不看此行
fprintf('PFM位移量(用游標尺比例算)為 %.2f (cm)\n',ratio);

% Store the result in a table
% offset_table = table(offset, vernier_scale, PFM, PFM_displacement,vs,ratio);
offset_table = table(offset, PFM, PFM_displacement,vs,ratio);


% % Save the processing image
% imwrite(img,'PFM_offset_v2.png');
saveas(pfm_offset_o,'PFM_offset_v2_o.png');%processing image 
saveas(pfm_offset,'PFM_offset_v2_n.png');%stract()
