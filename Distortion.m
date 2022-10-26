classdef Distortion
    methods
        function result = apply(self, data)
            arguments
                self
                data
            end
            %disp(size(data))
            data = 10^(-5) * data;% magnitude distortion
            %disp(size(data))
            data = exp(-3i/4 * pi) * data; % phase shift
            %disp(size(data))
            data = times(data, exp(-2i * pi * 0.00017 * linspace(1, size(data,2), size(data,2))) ); % frequency offset
            %disp(size(data))
            result = data + normrnd(0,10^(-14),[size(data,1),size(data,2)]); % channel noise
            %disp(size(data))
        end                                                     
        
        function recover = recover_frequency_offset(self, data, ltf_start)
            arguments
                self
                data
                ltf_start
            end
            ltf1 = data(ltf_start : ltf_start + 63);
            ltf2 = data(ltf_start + 64 : ltf_start + 127);
            freq_offset = sum(imag(rdivide(ltf1, ltf2))) /(2*pi*64*64);
            fprintf("Estimated Frequency Offset: %f\n",freq_offset);
            fprintf("---------------------------------------------------------\n");
            recover = times(data, exp(2i * pi * freq_offset * linspace(1, size(data, 2), size(data, 2))));
        end 
        
        function distortion = get_channel_distortion(self, data, ltf_preamble, ltf_start)
            ltf1 = data(ltf_start + 32 : ltf_start + 95);
            ltf2 = data(ltf_start + 96: ltf_start + 159);
            ltf1 = fft(ltf1);
            ltf2 = fft(ltf2);
            distortion = times((ltf1+ltf2)/2, ltf_preamble);
        end
        
    end
end
