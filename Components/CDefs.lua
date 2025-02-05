












_CDEFS = [[



    ////////////////////////////////////////////////////////////
    // Units ///////////

    struct Unit {
        unsigned short UnitType;
        unsigned short x;
        unsigned short y;
        short Health;
        short Energy;
        unsigned long Age; // Age in turns
        unsigned char Direction;

        short XForce;
        short YForce;
        // Adhesion tension is the amount of force a cells adhesion connections are exerting on it
        // to keep it stationary. Units trying to push this unit must push with a force greater than 
        // this units Mass + AdhesionTension values.
        unsigned short AdhesionTension;

        unsigned short GenomeID;
        unsigned short OrganismID;
        // The build tick is used to keep track of the last adhesion connection slot we checked for in the unit genome update
        unsigned short BuildTick;
        // The build index is what identifies a unit in its genome build data
        unsigned short BuildIndex;

        unsigned char UniqueArtID;
        unsigned long AdhesiveConnections[8];
        //
        unsigned short oldx;
        unsigned short oldy;
        unsigned short OldUnitType;
        unsigned char OldDirection;
        unsigned short newx;
        unsigned short newy;
        unsigned short newadx; // Adhesion adjustment x
        unsigned short newady; // Adhesion adjustment y       
        unsigned short adx; // Adhesion adjustment x
        unsigned short ady; // Adhesion adjustment y

        //
        unsigned char CustomData;
        unsigned char NeedsMovement;
    };


    typedef struct Unit LargeUnitList[10000001];
    typedef struct Unit MediumUnitList[1000001];
    typedef struct Unit SmallUnitList[10001];
    typedef struct Unit TinyUnitList[401];

    // A list of all gaps found in the unit list during cleaning
    typedef unsigned long GapList[10000000];

    

    ////////////////////////////////////////////////////////////
    // Genomes ///////////


    // Unit data for the blueprint build data. Holds the unit type of the
    // unit and the index of its siblings in the blueprint.
    // Used to build the unit during gameplay.
    typedef struct {
        unsigned long SelfType;
        unsigned short Siblings[8];
    } Genome_BuildData;

    // Unit data for the blueprint mapdata.
    // Holds information used to build the organism in the editor
    typedef struct {
        unsigned short UnitType;
        unsigned short Hue;
        unsigned char Rotation;
        unsigned char Split;
        unsigned char Trigger;
        short TriggerVal;
        unsigned char AdhesionConnections[8];
    } Genome_MapData;

    typedef struct {
        unsigned char Title[32];
        Genome_MapData MapData[26][26];
        Genome_BuildData BuildData[676];
        unsigned short StartBuildIndex; // The index of the starting unit in this organism (can be any index in the build data, just how it works right now)
        unsigned char EggType;
        unsigned char IsEmpty; // Whether or not an organism has been created in this organism slot
    } Genome_Organism;     


    /////////////////////////
    // Holds all the data for one genome
    typedef struct {
        unsigned char Title[32];
        unsigned long Index;
        unsigned char OrganismCount;
        Genome_Organism Organisms[6];
    } GenomeData;










    /////////////////////////
    // Holds all the surface data for a planet
    typedef struct {

        unsigned short BlockType;
        unsigned char Variation;
        char ElevationChange; // -1 to 1
        short Heat;
        unsigned char Gas;
        unsigned char GasPressure;
        unsigned short ObjectType;
		unsigned char ObjectData_1;
		unsigned char ObjectData_2;
		unsigned char ObjectData_3;
		unsigned char ObjectData_4;


    } SurfaceBlockData;



    ////////////////////////////////////////////////////////////

    void* malloc(size_t);                   
    void free(void*);
]]
ffi.cdef(_CDEFS)



print(ffi.sizeof("SurfaceBlockData[8192][8192]")/1024)




function NewLoveBytedataHelper(Ctype)

    local Memory = love.data.newByteData(ffi.sizeof(Ctype))
    ffi.fill(Memory:getFFIPointer(), ffi.sizeof(Ctype))
    local Data = ffi.cast(Ctype.."(&)", Memory:getFFIPointer())

return
Memory, Data
end


function NewCDataHelper(Ctype)

    local Memory = ffi.C.malloc(ffi.sizeof(Ctype))
    ffi.fill(Memory, ffi.sizeof(Ctype))
    local Data = ffi.cast(Ctype.."(&)", Memory)

return
Memory, Data
end

