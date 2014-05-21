classdef roi
    
    properties
        roiName
        
        % Three sets of patch handles
        roiPatchHandles
        
        % Three sets of polygons
        % Format: (x, y, h, w)
        % [x by x] matrix
        roiPolys
        
        % Format:
        % rectangular ROI   - x-coordinate vector, y-coordinate vector
        % spherical ROI     - (center x, center y, radius)
        % ellipsoid ROI     -
        % freehand ROI      - (x-coordinate vector, y-coordinate vector)
        %
        % Size:             variable
        roiCoordinates
        
        roiVisibility
        roiAlpha
        roiColor
        
        roiText
        roiShape
    end
    
    methods
        
        function obj = roi(RoiName)
            obj.roiName = RoiName;
            obj.roiPatchHandles = {};
            obj.roiPolys = [];
            obj.roiCoordinates = [];
            
            obj.roiVisibility = true;
            obj.roiAlpha = 0.5;
            obj.roiColor = [0 0 0];
            obj.roiText = RoiName;
            obj.roiShape = '';
        end
    end
end