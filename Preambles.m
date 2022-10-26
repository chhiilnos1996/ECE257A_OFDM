classdef Preambles <handle
    properties
        stf_f;
        ltf_f;
        stf_t;
    end
    methods
        function self = Preambles()
            self.stf_f = complex(zeros(1,64));
            self.stf_f(:,end-25:end) = sqrt(13/6) * [0, 0, 1+1i, 0, 0, 0, -1-1i, 0, 0, 0, 1+1i, 0, 0, 0, -1-1i, 0, 0, 0, -1-1i, 0, 0, 0, 1+1i, 0, 0, 0];
            self.stf_f(:,1:27) = sqrt(13/6) * [0, 0, 0, 0, -1-1i, 0, 0, 0, -1-1i, 0, 0, 0, 1+1i, 0, 0, 0, 1+1i, 0, 0, 0, 1+1i, 0, 0, 0, 1+1i, 0, 0];   
            
            self.ltf_f = complex(zeros(1,64));
            self.ltf_f(:,end-25:end) = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1];
            self.ltf_f(:,1:27) = [0, 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
        end

        function stf_data = stf_modulate(self, data)
            arguments
                self
                data
            end
            self.stf_t = ifft(self.stf_f);
            self.stf_t = self.stf_t(1:16);
            repeated_stf_t = repmat(self.stf_t, [1,10]); 

            %disp(size(data)) 1, 6560
            figure;
            plot(linspace(1,64, 64), abs(fftshift(fft(data,64))).^2);
            
          
            title('Power spectrum density of the OFDM data symbols')
            xlabel('frequency indices')
            ylabel('power spectrum density')
            saveas(gcf,'Power spectrum density of the OFDM data symbols.png');
            
            figure;
            plot(linspace(1,160,160),abs(repeated_stf_t));
            title('Magnitude of the samples in STF')
            xlabel('indices')
            ylabel('magnitude')
            saveas(gcf,'Magnitude of the samples in STF.png');
            stf_data = cat(2, repeated_stf_t, data);
        end
    
        function ltf_data = ltf_modulate(self, data)
            arguments
                self
                data
            end
            ltf_t = ifft(self.ltf_f);
            ltf_data = cat(2, ltf_t(end-31:end), ltf_t, ltf_t, data);
        end

        function result = demodulate(self, data, stf_start)
            arguments
                self
                data
                stf_start
            end
            result = data(stf_start+320:end);
        end
    end
end