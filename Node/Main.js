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
var attributesList = [];

const addMetadata = (_edition) => {
    let dateTime = Date.now();
    let tempMetadata = {
        name: `${namePrefix} #${_edition}`,
        description: description,
        image: `${baseUri}/${_edition}.png`,
        edition: _edition,
        date: dateTime,
        attributes: attributesList,
        compiler: compiler,
    };    
    metadataList.push(tempMetadata);
    attributesList = [];
};

const writeMetaData = (_data) => {
    fs.writeFileSync(`${basePath}/json/_metadata.json`, _data);
    console.log(`成功:_metadata.json`)
};

const saveMetaDataSingleFile = (_editionCount) => {
    let metadata = metadataList.find((meta) => meta.edition == _editionCount);
    fs.writeFileSync(
        `${basePath}/json/${_editionCount}.json`,
        JSON.stringify(metadata, null, 2)
    );
    console.log(`成功:json/${_editionCount}.json`)
};

const startCreating = async () => {
    let layerConfigIndex = 0;
    console.log(`需要生成:${MaxNFTLength}`)
    while (layerConfigIndex < MaxNFTLength) {
        addMetadata(layerConfigIndex);
        saveMetaDataSingleFile(layerConfigIndex);    
        layerConfigIndex++;
    }
    writeMetaData(JSON.stringify(metadataList, null, 2));
};

startCreating();