classdef imageSeries
    %IMAGESERIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        stack
        width
        height
        numberOfSlices
        sliceThickness
        roiList
        roiId
        sliderPositions
        pixelWidth
        pixelHeight
    end
    
    methods
        function obj = imageSeries(stack)
            
            obj.name = '';
            obj.stack = stack;
            obj.width = size(stack,2);
            obj.height = size(stack,1);
            obj.numberOfSlices = size(stack,3);
            obj.sliceThickness = 1;
            obj.roiList = {};
            obj.roiId = 0;
            obj.sliderPositions = [1 1 1];
            obj.pixelWidth = 1;
            obj.pixelHeight = 1;
        end
    end
end
