classdef BPSK
    properties
      data_indices;
      pilot_indices;
    end
    methods
        function self = BPSK()
            self.data_indices = [linspace(2,7,6) linspace(9,21,13) linspace(23,27,5) linspace(39,43,5) linspace(45,57,13) linspace(59,64,6)];
            self.pilot_indices = [8, 22, 44, 58];
        end

        function ofdm_symbols = modulate(self, bits)
            arguments
                self
                bits (3840,1) {mustBeNumeric}
            end
            bpskModulator = comm.BPSKModulator;
            bpsk_symbols = bpskModulator(bits);
            bpsk_symbols = reshape(bpsk_symbols,[],48);

            ofdm_symbols = zeros(size(bpsk_symbols,1),64); 
            ofdm_symbols = complex(ofdm_symbols);
            ofdm_symbols(:,self.data_indices) = bpsk_symbols;
            ofdm_symbols(:,self.pilot_indices) = 1;
        end

        function result = demodulate(self, ofdm_symbols)
            arguments
                self
                ofdm_symbols (80, 64) {mustBeNumeric}
            end
            bpsk_symbols = reshape(ofdm_symbols(:, self.data_indices),[],1);
            bpskDemodulator = comm.BPSKDemodulator;
            result = bpskDemodulator(bpsk_symbols);
        end
    end
end

