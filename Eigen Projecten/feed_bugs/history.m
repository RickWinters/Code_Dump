function[familytree] = history(creatures,i,familytree)

%familytree{creatures.generation(i),i}.parents = creatures.parents(i);
familytree{creatures.generation(i),i}.alive = creatures.alive(i);
familytree{creatures.generation(i),i}.endscore = creatures.score(i);


end