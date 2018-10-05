
% Programa de C�lculo das Curvas de Imped�ncia
% Autor: Luis Antonio Lopes / Modificado por: Julio Almeida e Mirian Rosa
% -----------------------------------------------------------------------

uiwait(msgbox('Este programa ir� executar o c�lculo das curvas de imped�ncia a partir dos dados extra�dos anteriomente. Clique em OK para prosseguir com a rotina.','Programa de C�lculo de Curvas','modal'));

% MUDAR MENSAGEM AQUI EMBAIXO DEPOIS

% O circuito consiste em um transdutor piezoel�trico em s�rie com um
% resistor simples, cuja tens�o (VR) ser� medida pelo NI DAQ USB-6211
% enquanto o piezoel�trico est� acoplado � estrutura a ser analizada,
% com o objetivo de se descobrir a corrente total do circuito enquanto
% o USB-6211 o excita com diferentes sinais de entrada para, posterior-
% mente, calcular-se as curvas de imped�ncia da estrutura.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Resistor proposto: 500 Ohms

% Sinais de excita��o:
% - chirp (sinal de frequ�ncia que varia de zero a 30KHz e tem dura��o de 1s)
% - aleat�rio (sinal gerado pela fun��o "randn" com zero de m�dia e 1 de vari�ncia)
% - idinput (sinal pseudoaleat�rio bin�rio previamente gerado pela fun��o "idinput")


prompt = {'Resist�ncia (valor real, em \Omega):','N�mero de ensaios:','N�mero de medidas por ensaio:','N�mero de pontos do sinal aleat�rio:','Frequ�ncia m�xima do sinal chirp:'};
title = 'Par�metros';
definput = {'518.6','10','3','250000','30000'}; % Padr�es definidos, respectivamente, para a resist�ncia, n�mero de ensaios e n�mero de medidas por ensaio.
opts.Interpreter = 'tex'; % Interpretador para o s�mbolo de Ohms (\Omega).
parametros = inputdlg(prompt,title,[1 45],definput,opts) % Entrada de par�metros, tendo os padr�es j� escritos como op��o.

r1 = str2double(parametros{1});             % Atribui��o dos par�metros
r1                                          % indicados manualmente para
num_ensaios = str2double(parametros{2});    % vari�veis.
num_ensaios
medidas = str2double(parametros{3});
medidas
num_pontos_sinal = str2double(parametros{4});
num_pontos_sinal
f_chirp = str2double(parametros{5});
f_chirp


for i=1:num_ensaios
    
    
    % Curva Imped�ncia - Sinal aleat�rio
        
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