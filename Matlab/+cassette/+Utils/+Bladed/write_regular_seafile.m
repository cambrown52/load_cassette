function write_regular_seafile(filepath,T,H,direction)
arguments (Input)
    filepath (1,1) string
    T (1,1) double {mustBePositive}
    H (1,1) double  {mustBePositive} = 2
    direction (1,1) double = 0
end
cassette.Utils.mustBeDegrees(direction)


contents=["source: cassette.Utils.write_regular_seafile Regular: H="+string(H)+"m, T="+string(T)+"Hz, theta="+string(direction)+"deg"
"identifier: "+string(datetime("now"))
"duration: 0"
"funit: Hz"
"dunit: rad"
"dconv: naut"
"seed: 1"
"amp method: det"
"phase method: rnd"
"dir method: det"
"components:"
sprintf("%f,%f,%f,0",H/2,1/T,direction*pi/180)];

writelines(contents,filepath)


end