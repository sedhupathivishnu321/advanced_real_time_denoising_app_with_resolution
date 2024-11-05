function advanced_real_time_denoising_app_with_resolution
    % Create the main GUI window
    fig = figure('Name', 'Advanced Real-Time Image Denoising', 'Position', [100, 100, 1200, 700]);

    % Display panel and control panel
    uipanel('Title', 'Controls', 'Position', [0.05 0.6 0.9 0.35]);
    displayPanel = uipanel('Title', 'Image Display', 'Position', [0.05 0.05 0.9 0.5]);
    
    % Four quadrants for displaying images
    originalAxes = axes('Parent', displayPanel, 'Position', [0.05 0.55 0.4 0.4]);
    noisyAxes = axes('Parent', displayPanel, 'Position', [0.55 0.55 0.4 0.4]);
    processedAxes = axes('Parent', displayPanel, 'Position', [0.05 0.05 0.4 0.4]);
    denoisedAxes = axes('Parent', displayPanel, 'Position', [0.55 0.05 0.4 0.4]);

    % UI controls
    uicontrol('Style', 'pushbutton', 'Position', [70, 530, 100, 30], 'String', 'Load Image', ...
              'Callback', @loadImage);

    uicontrol('Style', 'text', 'Position', [220, 740, 120, 20], 'String', 'Algorithm:');
    algMenu = uicontrol('Style', 'popupmenu', 'Position', [220, 720, 120, 20], ...
                        'String', {'Haar Wavelet', 'Gaussian Blur', 'Median Filter', 'Bilateral Filter', 'Wiener Filter'});

    % Noise level and filter strength sliders
    uicontrol('Style', 'text', 'Position', [350, 740, 100, 20], 'String', 'Noise Level:');
    noiseSlider = uicontrol('Style', 'slider', 'Position', [350, 720, 120, 20], 'Min', 0, 'Max', 100, 'Value', 20);

    uicontrol('Style', 'text', 'Position', [500, 740, 120, 20], 'String', 'Filter Strength:');
    filterSlider = uicontrol('Style', 'slider', 'Position', [500, 720, 120, 20], 'Min', 1, 'Max', 20, 'Value', 5);

    % RGB level sliders
    uicontrol('Style', 'text', 'Position', [650, 740, 60, 20], 'String', 'Red:');
    redSlider = uicontrol('Style', 'slider', 'Position', [650, 720, 80, 20], 'Min', 0, 'Max', 2, 'Value', 1);

    uicontrol('Style', 'text', 'Position', [750, 740, 60, 20], 'String', 'Green:');
    greenSlider = uicontrol('Style', 'slider', 'Position', [750, 720, 80, 20], 'Min', 0, 'Max', 2, 'Value', 1);

    uicontrol('Style', 'text', 'Position', [850, 740, 60, 20], 'String', 'Blue:');
    blueSlider = uicontrol('Style', 'slider', 'Position', [850, 720, 80, 20], 'Min', 0, 'Max', 2, 'Value', 1);

    % Brightness slider
    uicontrol('Style', 'text', 'Position', [950, 740, 80, 20], 'String', 'Brightness:');
    brightnessSlider = uicontrol('Style', 'slider', 'Position', [950, 720, 120, 20], 'Min', -1, 'Max', 1, 'Value', 0);

    % Resolution dropdown
    uicontrol('Style', 'text', 'Position', [100, 740, 100, 20], 'String', 'Resolution:');
    resolutionMenu = uicontrol('Style', 'popupmenu', 'Position', [100, 720, 100, 20], ...
                               'String', {'Original', '640x480', '800x600', '1024x768', '1280x960'});

    % Generate button
    uicontrol('Style', 'pushbutton', 'Position', [1100, 730, 100, 30], 'String', 'Generate', ...
              'Callback', @generateImage);

    % Save button
    uicontrol('Style', 'pushbutton', 'Position', [1100, 690, 100, 30], 'String', 'Save Image', ...
              'Callback', @saveImage);

    % Variables to store images
    originalImage = [];
    noisyImage = [];
    processedImage = [];
    denoisedImage = [];

    % Load image function
    function loadImage(~, ~)
        [file, path] = uigetfile({'*.png;*.jpg;*.bmp', 'Image Files (*.png, *.jpg, *.bmp)'});
        if isequal(file, 0)
            return;
        end
        imgPath = fullfile(path, file);
        originalImage = imread(imgPath);
        noisyImage = originalImage; % Initial noisy image
        processedImage = originalImage; % Initial processed image
        denoisedImage = originalImage; % Initial denoised image
        imshow(originalImage, 'Parent', originalAxes);
        title(originalAxes, 'Original Image');
    end

    % Generate image processing based on control values
    function generateImage(~, ~)
        if isempty(originalImage)
            errordlg('Please load an image first.', 'Error');
            return;
        end

        % Retrieve slider values
        noiseLevel = get(noiseSlider, 'Value');
        filterStrength = get(filterSlider, 'Value');
        redLevel = get(redSlider, 'Value');
        greenLevel = get(greenSlider, 'Value');
        blueLevel = get(blueSlider, 'Value');
        brightnessLevel = get(brightnessSlider, 'Value');
        
        % Add noise and display in Noisy Image quadrant
        noisyImage = imnoise(originalImage, 'salt & pepper', noiseLevel / 100);
        imshow(noisyImage, 'Parent', noisyAxes);
        title(noisyAxes, 'Noisy Image');

        % Apply color adjustments
        adjustedImage = cat(3, noisyImage(:,:,1) * redLevel, noisyImage(:,:,2) * greenLevel, noisyImage(:,:,3) * blueLevel);

        % Apply brightness adjustment
        adjustedImage = imadjust(adjustedImage, [], [], 1 + brightnessLevel);

        % Get selected algorithm
        algSelection = algMenu.Value;

        % Apply selected denoising algorithm
        switch algSelection
            case 1 % Haar Wavelet
                [cA, cH, cV, cD] = dwt2(rgb2gray(adjustedImage), 'haar');
                threshold = filterStrength * 5;
                cH(abs(cH) < threshold) = 0;
                cV(abs(cV) < threshold) = 0;
                cD(abs(cD) < threshold) = 0;
                denoisedImage = uint8(idwt2(cA, cH, cV, cD, 'haar'));

            case 2 % Gaussian Blur
                denoisedImage = imgaussfilt(adjustedImage, filterStrength);

            case 3 % Median Filter
                denoisedImage = medfilt3(adjustedImage, [filterStrength filterStrength 3]);

            case 4 % Bilateral Filter
                denoisedImage = imbilatfilt(adjustedImage, filterStrength, filterStrength * 2);

            case 5 % Wiener Filter
                denoisedImage = wiener2(rgb2gray(adjustedImage), [filterStrength filterStrength]);
        end

        % Resize based on resolution selection
        resolutionOption = get(resolutionMenu, 'Value');
        switch resolutionOption
            case 2
                denoisedImage = imresize(denoisedImage, [480 640]);
            case 3
                denoisedImage = imresize(denoisedImage, [600 800]);
            case 4
                denoisedImage = imresize(denoisedImage, [768 1024]);
            case 5
                denoisedImage = imresize(denoisedImage, [960 1280]);
        end

        % Display processed and denoised images
        imshow(adjustedImage, 'Parent', processedAxes);
        title(processedAxes, 'Processed Image');
        imshow(denoisedImage, 'Parent', denoisedAxes);
        title(denoisedAxes, 'Denoised Image');
    end

    % Save processed image function
    function saveImage(~, ~)
        [file, path] = uiputfile({'*.png', 'PNG Files (*.png)'}, 'Save Processed Image');
        if isequal(file, 0)
            return;
        end
        savePath = fullfile(path, file);
        imwrite(denoisedImage, savePath);
        msgbox('Image saved successfully!', 'Success');
    end
end
