function CWT_Fractal_Simulation_Quadrants
    % Create the figure for the GUI
    f = figure('Name', 'Wavelet Transform with Fractals - Four Quadrant View', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 700]);

    % Dropdown for wavelet selection
    uicontrol('Style', 'text', 'String', 'Select Wavelet Type:', 'Position', [20, 900, 120, 20]);
    waveletType = uicontrol('Style', 'popupmenu', 'String', {'Continuous (morse)', 'Continuous (bump)', 'Continuous (amor)', 'Discrete (Haar)', 'Discrete (db1)', 'Discrete (db2)'}, 'Position', [150, 900, 150, 20]);
    
    % Scaling Factor Slider
    uicontrol('Style', 'text', 'String', 'Scaling Factor:', 'Position', [300, 900, 80, 20]);
    scaleSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 50, 'Value', 10, 'Position', [400, 900, 150, 20]);
    
    % Time Control Slider
    uicontrol('Style', 'text', 'String', 'Time:', 'Position', [600, 900, 50, 20]);
    timeSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 1000, 'Value', 1, 'Position', [700, 900, 150, 20]);
    
    % Axes for Original Signal in top-left quadrant
    signalPlot = axes('Position', [.1, .55, .35, .35]);
    % Axes for Wavelet Coefficients Plot in top-right quadrant
    waveletPlot = axes('Position', [.55, .55, .35, .35]);
    % Axes for Full Wavelet Transform in bottom-left quadrant
    fullTransformPlot = axes('Position', [.1, .1, .35, .35]);
    % Axes for Frequency Spectrum (Power Spectrum) in bottom-right quadrant
    spectrumPlot = axes('Position', [.55, .1, .35, .35]);

    % Generate and Update Button
    uicontrol('Style', 'pushbutton', 'String', 'Generate', 'Position', [900, 900, 80, 30], 'Callback', @(src, event)updateTransform());

    % Time Update Button
    uicontrol('Style', 'pushbutton', 'String', 'Update Time', 'Position', [1000, 900, 80, 30], 'Callback', @(src, event)updateSignal());

    function updateTransform
        % Generate synthetic fractal signal
        t = linspace(0, 10, 1000); % Example time vector
        signal = generateFractalSignal(t); % Call custom fractal signal generator
        plotSignal(signal, t);
    end

    function updateSignal
        % Retrieve user parameters
        wavelet = waveletType.String{waveletType.Value};
        timeIndex = round(timeSlider.Value);
        
        % Generate synthetic fractal signal
        t = linspace(0, 10, 1000); % Example time vector
        signal = generateFractalSignal(t); % Call custom fractal signal generator
        if timeIndex > 1 && timeIndex <= length(signal)
            currentSignal = signal(1:timeIndex); % Take signal up to current time
            if startsWith(wavelet, 'Continuous')
                waveletName = extractAfter(wavelet, 'Continuous (');
                waveletName = extractBefore(waveletName, ')');
                [cwtData, frequencies] = cwt(currentSignal, waveletName); % Continuous wavelet transform
                plotSignalAndWavelet(currentSignal, cwtData, t(1:timeIndex), frequencies);
                plotFullTransform(cwtData, frequencies);
                plotFrequencySpectrum(currentSignal); % Plot frequency spectrum
            elseif startsWith(wavelet, 'Discrete')
                waveletName = extractAfter(wavelet, 'Discrete (');
                waveletName = extractBefore(waveletName, ')');
                [C, L] = wavedec(currentSignal, 3, waveletName); % Discrete wavelet transform
                dwtData = wrcoef('a', C, L, waveletName, 3); % Reconstruct approximation at level 3
                plotSignalAndWavelet(currentSignal, dwtData, t(1:timeIndex), []);
                plotFullTransform([], []); % No full transform for discrete
                plotFrequencySpectrum(currentSignal); % Plot frequency spectrum
            end
        end
    end

    % Function to plot Signal and Wavelet Coefficients
    function plotSignalAndWavelet(signal, waveletData, t, frequencies)
        % Plot Original Signal
        plot(signalPlot, t, signal);
        title(signalPlot, 'Original Signal');
        xlabel(signalPlot, 'Time');
        ylabel(signalPlot, 'Amplitude');

        % Plot wavelet coefficients or transformed data
        if ~isempty(waveletData)
            plot(waveletPlot, t(1:length(waveletData)), abs(waveletData)); % Use abs for visibility
            title(waveletPlot, 'Wavelet Coefficients');
            xlabel(waveletPlot, 'Time');
            ylabel(waveletPlot, 'Coefficient Magnitude');
        end
    end

    % Function to plot Full Wavelet Transform
    function plotFullTransform(cwtData, frequencies)
        if ~isempty(cwtData)
            imagesc('Parent', fullTransformPlot, 'XData', linspace(0, 10, size(cwtData, 2)), 'YData', frequencies, 'CData', abs(cwtData));
            axis(fullTransformPlot, 'xy');
            colormap(fullTransformPlot, 'jet');
            title(fullTransformPlot, 'Full Wavelet Transform');
            xlabel(fullTransformPlot, 'Time');
            ylabel(fullTransformPlot, 'Frequency');
            colorbar('peer', fullTransformPlot);
        else
            cla(fullTransformPlot); % Clear if there's no full transform data
        end
    end

    % Function to plot Frequency Spectrum (Power Spectrum)
    function plotFrequencySpectrum(signal)
        N = length(signal);
        fftSignal = fft(signal);
        P2 = abs(fftSignal/N);
        P1 = P2(1:N/2+1);
        f = (0:(N/2))/N;
        plot(spectrumPlot, f, P1);
        title(spectrumPlot, 'Frequency Spectrum');
        xlabel(spectrumPlot, 'Frequency (Hz)');
        ylabel(spectrumPlot, 'Amplitude');
    end

    % Nested function to generate fractal-like signal (1/f noise)
    function signal = generateFractalSignal(t)
        N = length(t);
        freqs = (1:N)/N; % Frequency spectrum
        powerSpectrum = 1 ./ freqs; % 1/f power spectrum
        phase = 2 * pi * rand(1, N); % Random phase
        signal = real(ifft(sqrt(powerSpectrum) .* exp(1i * phase))); % Generate fractal signal
    end
end
