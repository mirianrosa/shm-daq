
% Programa de Aquisi��o de Dados por Imped�ncia Eletromec�nica (Ensaios)
% Autor: Luis Antonio Lopes / Modificado por: Julio Almeida e Mirian Rosa
% -----------------------------------------------------------------------

uiwait(msgbox('Este programa ir� executar a rotina de extra��o de dados atrav�s do m�todo de imped�ncia eletromec�nica para posterior c�lculo de curvas. Clique em OK para prosseguir com a rotina.','Programa de Aquisi��o de Dados','modal'));

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


load ('sinal_excit_idinput_band125.mat')
% Carrega automaticamente o sinal de excita��o idinput que precisa estar na mesma 
% pasta e diret�rio deste c�digo-base.

% No caso de n�o existir o arquivo, gerar um novo sinal atr�ves da Command Window
% sinal_pseudrand_binario = idinput(250000,'PRBS',[0,1],[-1 1])
% e salvar a nova vari�vel (in Workspace) com o nome sinal_excit_idinput_band125.mat
% no mesmo diret�rio deste c�digo-base.

% Observa��es adicionais sobre a fun��o idinput: [0,1] - 125 kHz / [0,0.36] - 45 kHz
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configura��o DAQ

ao = analogoutput('nidaq','Dev2');   % Analogoutput cria um objeto analogoutput associado com o NIDAQ USB-6211, com sua identifica��o. Checar se a identifica��o do DAQ no "Measurement & Automation Explorer" da National Instruments � "Dev2". Caso negativo, renomear.
ch_out = addchannel(ao,0);           % SampleRate do DAQ em 250kHz.
ao.SampleRate = 250000;              % Garante que o tempo real de amostragem
ao.TriggerType = 'HwDigital';        % � compat�vel com o tempo programadono sinal chirp
ao.HwDigitalTriggerSource = 'PFI4';  % no sinal chirp
ao                                 

                                   
ai = analoginput('nidaq','Dev2');
set(ai,'InputType','Differential'); % Configura o AnalogInput para modo Diferencial (a diferen�a de um ponto e outro, pois os dois s�o pontos flutuantes)
ch_in = addchannel(ai,2);
ai.SampleRate = 250000;
ai.SamplesPerTrigger = 250000;
ai.TriggerType = 'Immediate';
ai.ExternalTriggerDriveLine = 'PFI4';
ai
   

                   

for i=1:num_ensaios
    
    
    % Ensaio sinal aleat�rio
    
    j=0;
    while (j<medidas)
    j=j+1;
    
    sinal_excit_aleat = randn(num_pontos_sinal,1);
    sinal_excit_aleat = sinal_excit_aleat./(max(abs(sinal_excit_aleat)));

    putsample(ao,[0])                  % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_aleat])    % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                          % � necess�rio iniciar o AnalogOutput primeiros para
    start(ai)                          % que este aguarde o in�cio do AnalogInput

    [data_aleat,time] = getdata(ai);   % Retorna o resultado.

    stop([ai,ao])                      % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                  % Recoloca o AnalogOutput em zero

    data_aleat = data_aleat./r1;      %  Como "data" � a tens�o entre os terminais do resistor,
                                      %  ent�o divide-se pela resist�ncia para achar a
                                      %  corrente.
    
    if (mean(abs(data_aleat))>8e-005) % Checar se houve erro da medida
        
    out_aleat(:,(j+(i-1)*3))= data_aleat;
    in_aleat(:,(j+(i-1)*3))= sinal_excit_aleat;
        
    else
        'Erro: valor zero ou muito pr�ximo de zero'
        j=j-1;
    end
                                      
    'Realizar nova medida'
    
    pause

    end
    
    
    % Ensaio sinal chirp
           
    j=0;
    while (j<medidas)
    j=j+1;
                                                         % Total de 250k amostras
    t_chirp = 0.000004:0.000004:1;                       % In�cio @ DC, 
    sinal_excit_chirp = (chirp(t_chirp,0,1,f_chirp))';   % De zero Hz at� 30kHz em t=1 sec

    putsample(ao,[0])                  % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_chirp])    % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                          % � necess�rio iniciar o AnalogOutput primeiros para
    start(ai)                          % que este aguarde o in�cio do AnalogInput

    [data_chirp,time] = getdata(ai);   % Retorna o resultado.

    stop([ai,ao])                      % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                  % Recoloca o AnalogOutput em zero

    data_chirp = data_chirp./r1;      %  Como "data" � a tens�o entre os terminais do resistor,
                                      %  ent�o divide-se pela resist�ncia para achar a
                                      %  corrente.
                         
    if (mean(abs(data_chirp))>8e-005)    % Checar se houve erro da medida
        
    out_chirp(:,(j+(i-1)*3))= data_chirp;
    in_chirp(:,(j+(i-1)*3))= sinal_excit_chirp;

    else
        'Erro: valor zero ou muito pr�ximo de zero'
        j=j-1;
    end
    
    'Realizar nova medida'
    
    pause

    end
    
    % Ensaio sinal idinput
    
    j=0;
    while (j<medidas)
    j=j+1;
    
    putsample(ao,[0])                  % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_idinput_band125])  % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                          % � necess�rio iniciar o AnalogOutput primeiros para
    start(ai)                          % que este aguarde o in�cio do AnalogInput

    [data_idinput,time] = getdata(ai);   % Retorna o resultado.

    stop([ai,ao])                      % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                  % Recoloca o AnalogOutput em zero

    data_idinput = data_idinput./r1;      %  Como "data" � a tens�o entre os terminais do resistor,
                                          %  ent�o divide-se pela resist�ncia para achar a
                                          %  corrente.
                                      
    if (mean(abs(data_idinput))>8e-005)    % Checar se houve erro da medida
        
    out_idinput(:,(j+(i-1)*3))= data_idinput;
    in_idinput(:,(j+(i-1)*3))= sinal_excit_idinput_band125;

    else
        'Erro: valor zero ou muito pr�ximo de zero'
        j=j-1;
    end
    
    'Realizar nova medida'
    
    pause

    end
    
       
    i
    
    'Fim das medidas. Modificar dano da barra.'
    
    pause

end

uiwait(msgbox('Salve os dados do workspace em um arquivo *.mat','Programa de Aquisi��o de Dados','modal'));
                                   