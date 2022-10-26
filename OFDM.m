classdef OFDM
    methods
        function self = OFDM()
        end

        function prefixed_samples = modulate(self,ofdm_symbols)
            arguments
                self
                ofdm_symbols (80,64) {mustBeNumeric}
            end
            samples = ifft(ofdm_symbols, 64, 2);
            prefixed_samples = cat(2, samples(:, end-15:end), samples);
            prefixed_samples = reshape(prefixed_samples, 1, []);
        end
        
        function ofdm_symbols = demodulate(self, prefixed_samples)
            arguments
                self
                prefixed_samples (1, 6400) {mustBeNumeric}
            end
            prefixed_samples = reshape(prefixed_samples, [], 80);
            samples = prefixed_samples(:, 17:end);
            ofdm_symbols = fft(samples, 64, 2);
        end
    end
end


