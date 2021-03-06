
% C�lculo das curvas de imped�ncia
% --------------------------------

mensagem = helpdlg('Este programa ir� executar a rotina de extra��o de curvas de imped�ncia atrav�s do m�todo de imped�ncia eletromec�ncia. Aperte qualquer tecla na tela de comando para prosseguir com a rotina', 'Programa de ensaio SHM-EMI')

pause
;
% Circuito: resistor simples
% Resistor utilizado na disserta��o de Mestrado: 470 ohms
% Sinal excita��o: chirp (zero a 30KHz e dura��o de 1s)
%                  aleat�rio (fun��o "randn" com zero de m�dia e 1 de vari�ncia)
%                  idinput

%parametros = inputdlg({'Resist�ncia (ohms - default 470)','N�mero de ensaios (default 10)','N�mero medidas por ensaio (default 3)'},'PAR�METROS') % Inserir valor dos par�metros
%r1=parametros{1};          % valor resist�ncia (proposta: 470)
r1=500;

%num_ensaios = parametros{2};         % N�mero de ensaios (proposta: 10)
num_ensaios = 1;
%medidas = parametros{3};             % N�mero medidas por ensaio (proposta: 3)
medidas = 1;



for i=1:num_ensaios
    
    
    % Modelo 1
        
    % Curva imped�ncia sinal aleat�rio
        
    for j=1:medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_aleat(:,(j+(i-1)*medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_aleat(:,(j+(i-1)*medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));

    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);
    
    end

    
    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Imped�ncia real do circuito
    
    curva_imped_mod1_aleat(i,:)=Z_final2;
        
    % Curva imped�ncia sinal chirp
    
    Z_media2=Z_media2';
    
    for j=1:medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_chirp(:,(j+(i-1)*medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_chirp(:,(j+(i-1)*medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));
    
    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);

    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Imped�ncia real do circuito
    
    curva_imped_mod1_chirp(i,:)=Z_final2;
   
    
    % Curva imped�ncia sinal idinput
    
    Z_media2=Z_media2';
    
    for j=1:medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_idinput(:,(j+(i-1)*medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_idinput(:,(j+(i-1)*medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));
    
    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);

    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Imped�ncia real do circuito
    
    curva_imped_mod1_idinput(i,:)=Z_final2;
        
    Z_media2=Z_media2';
    
    
end

curva_imped_mod1_aleat=curva_imped_mod1_aleat';
curva_imped_mod1_chirp=curva_imped_mod1_chirp';
curva_imped_mod1_idinput=curva_imped_mod1_idinput';
 
x=0:1:511;
plot(x,curva_imped_mod1_idinput(:,1))