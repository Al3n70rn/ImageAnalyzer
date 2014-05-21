classdef study
    %IMAGESERIES Summary of this class goes here
    %   Detailed explanation goes here
    properties
        name
        fileName
        pathName
        
        
        imageSeriesList
        progressList
        
        
        manager
        visualization
        
        imageSeriesId
        
    end
    
    methods
        
        function obj = study(fileName)
            obj.name        = fileName(1:end-4);
            obj.fileName    = fileName;
            obj.pathName    = '';
            
            
            obj.imageSeriesList = {};
            obj.progressList = {};
            obj.manager = {};
            obj.visualization = {};
            obj.imageSeriesId = 0;
            
        end
    end
end