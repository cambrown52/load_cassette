function tCJ=crossjoin(tL,tR)
arguments
    tL table
    tR table
end


tL.key(:)=1;
tR.key(:)=1;
tCJ=outerjoin(tL,tR,'Keys','key','MergeKeys',true,'Type','full');
tCJ.key=[];
end
