function out = isInBetween(idx,windowNum,windowsize)

rangeMat=idx/windowsize;
out=0;
for i=1:size(rangeMat,1)
    range=rangeMat(i,:);
    if(windowNum>=range(1)&&windowNum<=range(2))
        out=1;
        break;
    end
end

end