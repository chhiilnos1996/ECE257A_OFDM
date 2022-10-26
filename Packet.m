classdef Packet <handle
    properties
      length;
      data;
      bpsk;
      ofdm;
      preamble;
      distortion;
      r;
      e;
      stf_start;
      stf_region;
    end
    methods
        function self = Packet()
            self.length = 3840;
            self.bpsk = BPSK();
            self.ofdm = OFDM();
            self.preamble = Preambles();
            self.distortion = Distortion();
            self.data = double(randi([0, 1], [self.length, 1]));
        end

        function construction(self)   
            %disp(size(self.data)); % 3840, 1 
            self.data = self.bpsk.modulate(self.data);
            %disp(size(self.data)); % 80, 64
            self.data = self.ofdm.modulate(self.data);
            %disp(size(self.data)); % 1, 6400
            self.data = self.preamble.ltf_modulate(self.data);
            %disp(size(self.data)); % 1, 6560
            self.data = self.preamble.stf_modulate(self.data);
            %disp(size(self.data)); % 1, 6720
        end
        
        function transmission(self)
            %fprintf('transmission start\n');
            %disp(size(self.data)); 1, 6720
            self.data = cat(2, zeros(1,100), self.data);
            self.data = self.distortion.apply(self.data);
            %fprintf('transmission end\n');
            %disp(size(self.data)); 1, 6820

            % plot stf samples
            figure;
            plot(linspace(1,160,160),abs(self.data(:,101:260)));
            title('Magnitude of the samples in STF after distortion')
            xlabel('indices')
            ylabel('magnitude')
            saveas(gcf,'Magnitude of samples in STF after distortion.png');
           
            
        end
        
        function detection(self)
            %fprintf('detection\n');
            %disp(size(self.data)); % 1, 6820
            len = size(self.data,2)-31;
            self.r = zeros(1,len);
            self.e = zeros(1,len);
            for i=1:len
                self.r(i) = abs(dot(self.data(i : i + 15), self.data(i + 16 : i + 31)));
                self.e(i) = dot(self.data(i : i + 15), self.data(i : i + 15));
            end
            
            % plot detection
            figure;
            plot(linspace(1,len,len), self.r, 'g',linspace(1,len,len), self.e, 'b');
            title('Self-correlation results')
            xlabel('indices')
            ylabel('value')
            saveas(gcf,'Self-correlation results.png');

            self.stf_region = find(abs(self.r) > 0.999 * abs(self.e));
            self.stf_region = self.stf_region+31;
            fprintf("Indices of STF region:\n ");
            disp(self.stf_region);
        end
        
        function synchronization(self)
            %disp(size(self.data)); 1, 6820
            %disp(size(self.preamble.stf_t)); 1, 16
            cross_correlation = xcorr(self.data, self.preamble.stf_t);
            cross_correlation = cross_correlation(size(self.data,2)-size(self.preamble.stf_t,2)+1+15:end);
            %disp(size(cross_correlation)); 1, 6820
            len = size(cross_correlation,2);

            % plot cross correlation
            figure;
            plot(linspace(1,len,len),abs(cross_correlation));
            title('Cross-correlation results')
            xlabel('indices')
            ylabel('value')
            saveas(gcf,'Cross-correlation results.png');
            
            self.stf_start = find(abs(cross_correlation) > 0.9 * max(abs(cross_correlation)));
            fprintf("Indices of STF starting time:\n ");
            disp(self.stf_start);
            %disp(size(self.stf_start));
            fprintf("---------------------------------------------------------\n");
            self.stf_start = self.stf_start(1);
        end
        
        function decoding(self)
            ltf_start = self.stf_start + 160;
            %disp(size(self.data)); 1, 6820
            self.data = self.distortion.recover_frequency_offset(self.data, ltf_start);
            H = self.distortion.get_channel_distortion(self.data, self.preamble.ltf_f, ltf_start);
            fprintf("Channel Distortion:\n");
            disp(H);
            fprintf("---------------------------------------------------------\n");
   
            self.data = self.preamble.demodulate(self.data, self.stf_start);
            %fprintf('after preamble demodulate\n');
            %disp(size(self.data)); 1, 6400
     
            self.data = self.ofdm.demodulate(self.data);
            %fprintf('after ofdm demodulate\n');
            %disp(size(self.data));  80, 64

            zeros = find(H==0);   
            nonzeros = find(H~=0);
            %disp(self.data);
            self.data(:,nonzeros) = self.data(:,nonzeros)./repmat(H(nonzeros), [size(self.data, 1), 1]);
            self.data(:,zeros) = 0;
            %fprintf('after divide\n');
            %disp(size(self.data)); 80, 64

            self.data = self.bpsk.demodulate(self.data);
            %fprintf('after bpsk demodulate\n');
            %disp(size(self.data)); 3840, 1
          
        end
        
    end
end

