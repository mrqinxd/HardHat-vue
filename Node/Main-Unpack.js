const basePath = process.cwd();
const fs = require("fs");
const {
    baseUri,
    description,    
    namePrefix,
    compiler,
    MaxNFTLength,    
    unpack 
} = require(`${basePath}/config.js`);

var metadataList = [];

const addMetadata = (_edition) => {
    metadataList = {
        name: `${unpack.namePrefix}`,
        description: unpack.description,
        image: `${unpack.baseUri}/${_edition}.png`,
        attributes:[]
    };
};

const saveMetaDataSingleFile = (_editionCount) => {
    fs.writeFileSync(
        `${basePath}/unpackJson/${_editionCount}.json`,
        JSON.stringify(metadataList, null, 2)
    );
    console.log(`成功:json/${_editionCount}.json`)
};

const startCreatingUnpack = async () => {
    addMetadata(unpack.jsonName);
    saveMetaDataSingleFile(unpack.jsonName);
};

startCreatingUnpack();