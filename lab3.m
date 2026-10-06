%% Лабораторная работа №3. Вариант 7
% Работа с цветом — функция rgb2ind
% Совместимо с MATLAB R2024a/R2024b + Image Processing Toolbox
%
% Исходное изображение варианта: 07_02_Variant.jpg
% Поместите этот .m-файл и изображение в одну папку.
% Если изображение не найдено, программа предложит выбрать его вручную.

clear;
close all;
clc;

%% 1. Загрузка изображения варианта
imageFile = '07_02_Variant.jpg';

if ~isfile(imageFile)
    [fileName, pathName] = uigetfile( ...
        {'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', 'Файлы изображений'}, ...
        'Выберите изображение варианта 7');

    if isequal(fileName, 0)
        error('Изображение не выбрано. Выполнение прекращено.');
    end

    imageFile = fullfile(pathName, fileName);
end

RGB = imread(imageFile);

% rgb2ind требует RGB-изображение MxNx3.
% Этот блок делает программу устойчивой, если файл окажется полутоновым.
if ndims(RGB) == 2
    RGB = repmat(RGB, [1 1 3]);
elseif size(RGB, 3) > 3
    RGB = RGB(:, :, 1:3);
end

figure('Name', 'Исходное изображение', 'NumberTitle', 'off');
imshow(RGB);
title('Исходное изображение — вариант 7');

fprintf('Исходное изображение: %d x %d x %d, класс %s\n', ...
    size(RGB,1), size(RGB,2), size(RGB,3), class(RGB));

% Проверим, является ли RGB-файл фактически серым изображением.
isGrayRGB = isequal(RGB(:,:,1), RGB(:,:,2)) && isequal(RGB(:,:,2), RGB(:,:,3));
if isGrayRGB
    fprintf(['Примечание: файл записан как RGB, но R=G=B для всех пикселей, ' ...
             'то есть изображение фактически полутоновое.\n']);
end

%% 2. Равномерное квантование: tol = 0.99, 0.5, 0.25, 0.1
% По методичке используется [X,map] = rgb2ind(RGB,tol).
% В MATLAB R2024 эта форма синтаксиса поддерживается.

tolValues = [0.99 0.5 0.25 0.1];
Xuniform = cell(size(tolValues));
mapUniform = cell(size(tolValues));
figUniform = gobjects(size(tolValues));

fprintf('\nРАВНОМЕРНОЕ КВАНТОВАНИЕ\n');
fprintf('---------------------------------------------------------------\n');
fprintf('   tol       max цветов по формуле       фактически в map\n');
fprintf('---------------------------------------------------------------\n');

for k = 1:numel(tolValues)
    tol = tolValues(k);

    % По умолчанию rgb2ind использует dithering, как в примерах методички.
    [Xuniform{k}, mapUniform{k}] = rgb2ind(RGB, tol);

    maxColors = (floor(1/tol) + 1)^3;
    actualColors = size(mapUniform{k}, 1);

    fprintf('%6.2f             %6d                    %6d\n', ...
        tol, maxColors, actualColors);

    figUniform(k) = figure( ...
        'Name', sprintf('Равномерное квантование tol = %g', tol), ...
        'NumberTitle', 'off');
    imshow(Xuniform{k}, mapUniform{k});
    title(sprintf('Равномерное квантование: tol = %g, цветов = %d', ...
        tol, actualColors));
end

%% 3. Неравномерное квантование: n = 2, 10, 100, 1000
% При задании числа цветов rgb2ind использует квантование
% с минимальной дисперсией (minimum variance quantization).

nValues = [2 10 100 1000];
Xnonuniform = cell(size(nValues));
mapNonuniform = cell(size(nValues));
figNonuniform = gobjects(size(nValues));

fprintf('\nНЕРАВНОМЕРНОЕ КВАНТОВАНИЕ\n');
fprintf('---------------------------------------\n');
fprintf(' задано n          фактически в map\n');
fprintf('---------------------------------------\n');

for k = 1:numel(nValues)
    n = nValues(k);

    [Xnonuniform{k}, mapNonuniform{k}] = rgb2ind(RGB, n);
    actualColors = size(mapNonuniform{k}, 1);

    fprintf('%7d                 %7d\n', n, actualColors);

    figNonuniform(k) = figure( ...
        'Name', sprintf('Неравномерное квантование n = %d', n), ...
        'NumberTitle', 'off');
    imshow(Xnonuniform{k}, mapNonuniform{k});
    title(sprintf('Неравномерное квантование: n = %d, цветов = %d', ...
        n, actualColors));
end

%% 4. Краткий анализ результатов
fprintf('\nАНАЛИЗ РЕЗУЛЬТАТОВ\n');
fprintf(['1) При уменьшении tol число допустимых уровней растёт, поэтому ' ...
         'квантованное изображение становится ближе к исходному.\n']);
fprintf(['2) При увеличении n при неравномерном квантовании сохраняется ' ...
         'больше оттенков, поэтому уменьшаются ступенчатые переходы яркости.\n']);

if isGrayRGB
    fprintf(['3) В данном варианте R=G=B, поэтому фактически используются только ' ...
             'серые цвета вдоль диагонали RGB-куба. Из-за этого реальная карта ' ...
             'цветов заметно меньше теоретического максимума (floor(1/tol)+1)^3.\n']);
    fprintf(['4) Исходный файл uint8 имеет не более 256 различных серых RGB-троек, ' ...
             'поэтому запрос n=1000 не может создать 1000 реально используемых ' ...
             'оттенков для этого изображения.\n']);
end

%% 5. Редактор цветовых карт (интерактивный пункт)
% В MATLAB R2024 команда colormapeditor доступна.
% По умолчанию автоматическое открытие отключено, чтобы скрипт не создавал
% восемь последовательных интерактивных остановок.
%
% Чтобы выполнить пункт 5 лабораторной полностью:
% 1) поставьте openColormapEditors = true;
% 2) запустите только эту секцию или весь скрипт;
% 3) после редактирования каждой карты вернитесь в Command Window и нажмите Enter.

openColormapEditors = false;

if openColormapEditors
    allFigures = [figUniform, figNonuniform];

    for k = 1:numel(allFigures)
        if isgraphics(allFigures(k))
            figure(allFigures(k));
            colormapeditor;
            fprintf(['Редактируйте карту цветов текущего изображения. ' ...
                     'После завершения нажмите Enter в Command Window.\n']);
            input('', 's');
        end
    end
end

%% 6. Битовая глубина экрана и ответы к заданию
% Старое меню Windows «256 цветов / High Color / True Color» в современных
% версиях Windows обычно отсутствует, поэтому ниже приводится смысл терминов.
%
% 256 цветов       = 8 бит/пиксель: максимум 2^8 = 256 индексов цветов.
% High Color 16 бит = обычно 16 бит/пиксель. Часто используется RGB 5-6-5:
%                     5 бит R, 6 бит G, 5 бит B => 2^16 = 65536 цветов.
%                     В некоторых старых системах встречался вариант 5-5-5
%                     (32768 цветов + служебный бит).
% True Color 32 бит = обычно 8 бит R + 8 бит G + 8 бит B + 8 бит alpha/служебных
%                     данных. Видимых RGB-цветов: 2^24 = 16777216.

try
    screenDepth = get(groot, 'ScreenDepth');
    fprintf('\nТекущая глубина экрана, сообщаемая MATLAB: %g бит/пиксель.\n', screenDepth);
catch
    fprintf('\nMATLAB не смог получить свойство ScreenDepth на этой системе.\n');
end

%% Ответы на контрольные вопросы
% Вопрос 1.
% n = (floor(1/tol)+1)^3, потому что по каждой из трёх координат R, G, B
% получается floor(1/tol)+1 уровней квантования. Число комбинаций трёх
% независимых координат равно кубу этого количества.
%
% Для заданных tol теоретический максимум:
% tol=0.99 -> (1+1)^3  = 8;
% tol=0.50 -> (2+1)^3  = 27;
% tol=0.25 -> (4+1)^3  = 125;
% tol=0.10 -> (10+1)^3 = 1331.
% rgb2ind удаляет из карты цвета, которых нет в исходном изображении, поэтому
% фактическое число строк map может быть меньше.
%
% Вопрос 2.
% При неравномерном квантовании RGB-куб делится на прямоугольные области
% различного размера в зависимости от распределения цветов изображения.
% Используется метод минимальной дисперсии: больше областей выделяется там,
% где цветов/пикселей больше или где их разброс существеннее.
%
% Вопрос 3.
% RGB              : M x N x 3, обычно uint8 для JPEG данного варианта.
% Xuniform/Xnonuniform: M x N индексные изображения, uint8 при <=256 цветах
%                     в карте и uint16 при карте >256 цветов.
% mapUniform/mapNonuniform: K x 3, тип double, значения компонентов в [0,1].

fprintf('\nПЕРЕМЕННЫЕ В РАБОЧЕМ ПРОСТРАНСТВЕ\n');
whos RGB Xuniform mapUniform Xnonuniform mapNonuniform

%% Дополнительно: таблица размеров карт для отчёта
fprintf('\nСводная таблица для отчёта:\n');
for k = 1:numel(tolValues)
    fprintf('Равномерное:   tol=%g -> %d цветов, X: %s\n', ...
        tolValues(k), size(mapUniform{k},1), class(Xuniform{k}));
end
for k = 1:numel(nValues)
    fprintf('Неравномерное: n=%d   -> %d цветов, X: %s\n', ...
        nValues(k), size(mapNonuniform{k},1), class(Xnonuniform{k}));
end
