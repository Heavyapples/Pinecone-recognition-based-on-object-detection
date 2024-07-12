% 指定数据集的路径
dataFolder = 'E:\代码接单\松果识别\增强后的松果';

% 读取文件夹中的所有xml文件
xmlFiles = dir(fullfile(dataFolder, '*.xml'));

% 初始化一个空的ground truth数据结构
gTruth = table('Size', [0 2], 'VariableTypes', {'string', 'cell'}, ...
    'VariableNames', {'imageFilename', 'pinecone'});

% 遍历所有的xml文件
for i = 1:length(xmlFiles)
    % 读取xml文件
    xmlFile = xmlFiles(i).name;
    xDoc = xmlread(fullfile(dataFolder, xmlFile));

    % 提取bounding box的信息
    bndboxNodes = xDoc.getElementsByTagName('bndbox');
    
    bboxes = []; % 初始化空的bboxes
    for j = 0:bndboxNodes.getLength()-1
        bndboxNode = bndboxNodes.item(j);
        xmin = str2double(bndboxNode.getElementsByTagName('xmin').item(0).getTextContent());
        ymin = str2double(bndboxNode.getElementsByTagName('ymin').item(0).getTextContent());
        xmax = str2double(bndboxNode.getElementsByTagName('xmax').item(0).getTextContent());
        ymax = str2double(bndboxNode.getElementsByTagName('ymax').item(0).getTextContent());

        % 创建一个标签数据
        bbox = [xmin, ymin, xmax-xmin, ymax-ymin];
        bboxes = [bboxes; bbox];  % 添加到bboxes
    end

    % 读取原始图像
    originalImage = imread(fullfile(dataFolder, strrep(xmlFile, '.xml', '.png')));
    originalSize = size(originalImage);

    % 将这个数据源和标签数据添加到ground truth数据结构中
    gTruth = [gTruth; {fullfile(dataFolder, strrep(xmlFile, '.xml', '.png')), {bboxes}}];
end

% 创建一个训练选项
options = trainingOptions('adam', ...
    'MiniBatchSize', 1, ...
    'MaxEpochs', 10, ...
    'InitialLearnRate', 1e-3, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 200, ...
    'LearnRateDropFactor', 0.5);

% 训练一个目标检测模型
detector = trainFasterRCNNObjectDetector(gTruth, 'vgg16', options);

% 保存模型
save('pinecone_detector2.mat', 'detector');