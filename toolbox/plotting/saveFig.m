function saveFig(parentPath,name,fig)
%SAVEFIG Summary of this function goes here
%   Detailed explanation goes here
arguments
    parentPath string
    name string
    fig = gcf
end
fig.Renderer = 'painters';
% fig.Renderer = 'zbuffer';
savefig(fig,fullfile(parentPath,name))
exportgraphics(fig,fullfile(parentPath,name)+".png",'Resolution',1000)
% savePDF(fig,fullfile(parentPath,name))
% exportgraphics(fig,fullfile(parentPath,name)+".pdf")
exportgraphics(fig,fullfile(parentPath,name)+".pdf",'ContentType','vector')
% print(fig, '-dpdf', '-r600', fullfile(parentPath,name)+".pdf");
saveas(fig,fullfile(parentPath,name)+".svg",'svg')
% exportgraphics(gcf, fullfile(parentPath,name)+".svg", 'ContentType', 'auto');
% print(fig, '-dsvg', fullfile(parentPath,name)+".svg")
% saveas(fig,fullfile(parentPath,name)+".eps",'epsc')
end

