function file = savePDF(psname,savename,file)
%Function to save space in main scripts.  Tries a bunch of different
%methods to save pdf of results.

try
    ps2pdf('psfile', psname, 'pdffile', savename, 'gscommand', '/usr/local/bin/gs-noX11');%, ...
catch err
    try
        ps2pdf('psfile', psname, 'pdffile', savename);
    catch err
        try
            path = 'C:\Program Files\gs\gs9.10\bin\gswin64c.exe';
            ps2pdf('psfile', psname, 'pdffile', savename, 'gscommand', path);
        catch err
            try
                path = 'C:\Program Files\gs\gs9.14\bin\gswin64c.exe';
                ps2pdf('psfile', psname, 'pdffile', savename, 'gscommand', path);
            catch err
                try
                    path = 'C:\Program Files\gs\gs9.14\bin\gswin32c.exe'; % C:\Program Files\gs\gs9.14\bin
                    ps2pdf('psfile', psname, 'pdffile', savename, 'gscommand', path);
                catch err
                    try
                        ps2pdf('psfile', psname, 'pdffile', savename, 'gscommand', '/usr/local/bin/gs-X11');%, ...
                    catch err
                        try
                            path = 'C:\Program Files\gs\gs9.19\bin\gswin64c.exe';
                            ps2pdf('psfile', psname, 'pdffile', savename, 'gscommand', path);
                        catch err
                            try
                                path = 'C:\Program Files\gs\gs9.20\bin\gswin64c.exe';
                                ps2pdf('psfile', psname, 'pdffile', savename, 'gscommand', path);
                            catch err
                                disp([ 'No figures available to save to ' psname ]);
                               disp(['No figures available to save to ' psname ]);
                            end
                        end
                    end
                end
            end
        end
    end
end

