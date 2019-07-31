
function[Creaturenet] = CreateCreature

Creaturenet = network;
Creaturenet.NumInputs = 1;
Creaturenet.Numlayers = 2;

Creaturenet.inputConnect(1,[1:Creaturenet.NumInputs]) = 1;
Creaturenet.layerConnect(2,1) = 1;
Creaturenet.biasConnect = [1; 1];

Creaturenet.inputs{1}.size = 2;
Creaturenet.layers{1}.size = 3;
Creaturenet.layers{2}.size = 4;

Creaturenet.layers{1}.transferFCN = 'logsig';
Creaturenet.layers{2}.transferFCN = 'softmax';

Creaturenet.outputConnect(1,2) = 1;

Creaturenet.Iw{1} = rand(size(Creaturenet.Iw{1},1),size(Creaturenet.Iw{1},2));
Creaturenet.Lw{2,1} = rand(size(Creaturenet.Lw{2,1},1),size(Creaturenet.Lw{2,1},2));
Creaturenet.b{1} = rand(size(Creaturenet.b{1},1),size(Creaturenet.b{1},2));
Creaturenet.b{2} = rand(size(Creaturenet.b{2},1),size(Creaturenet.b{2},2));



%view(Creaturenet)
end