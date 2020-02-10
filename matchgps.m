function [Deployment_roomcat_save_temp, nomatch] = matchgps(Deployment_roomcat_save, gpsmain1, gpsmain2, nomatch, khrcwatch1, khrcwatch2)
%macthgps by Evan Coffey


%   This function matches gps categories to user beacon timeseries for
%   categorizing exposure

%inputs:
% a single user beacon deployment entry (table)
% and the gps master timeseries

%outputs:
% time-matched beacon deployment

%%

% Create a column in the Deployment_roomcat for the gps to go
Deployment_roomcat_save.GPS_cat = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.GPS_Buffer=NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.GPS_flag=NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.GPS_lat=NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.GPS_lon=NaN(height(Deployment_roomcat_save),1);


User = Deployment_roomcat_save.UserID(1);

if ~contains(User,'BM') % If the user is not from KHRC cohort

    
    if ~contains(User,'_PM')
            %Use the start and end times of the beacon deployment
            ts = datetime(Deployment_roomcat_save.TimeMinuteRounded(1),'ConvertFrom', 'datenum');
            te = datetime(Deployment_roomcat_save.TimeMinuteRounded(end),'ConvertFrom', 'datenum');

            disp(['from ', datestr(ts), ' to ', datestr(te)]);

                    try
                        matchind = isbetween((datetime(gpsmain1.(3),'ConvertFrom', 'datenum')),ts,te);
                        numatch = sum(matchind); % number of minute matches

                        if numatch>0
                            %disp([num2str(numatch), ' time matches found']);

                            [C,ia,ib] = innerjoin(Deployment_roomcat_save,gpsmain1,'LeftKeys',[17,5],'RightKeys',[3,1]);

                            if isempty(ia)
                                nomatch = nomatch+1; %Add one to nomatch because user was not wearing the watch
                                disp('Watch not deployed with this user')%User not wearing the watch conditional
                            else
                            disp([num2str(length(ia)), ' time matches found with this user']);
                            Deployment_roomcat_save.GPS_cat(ia)= gpsmain1.dataInside(ib);
                            Deployment_roomcat_save.GPS_Buffer(ia) = gpsmain1.bufferUsed(ib);
                            Deployment_roomcat_save.GPS_flag(ia) = gpsmain1.dataflag0(ib);
                            Deployment_roomcat_save.GPS_lat(ia)=gpsmain1.latSeries(ib);
                            Deployment_roomcat_save.GPS_lon(ia)=gpsmain1.lonSeries(ib);
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;
                            end

                        else
                             disp('No data exists for the GPS watch at these times');
                             nomatch = nomatch+1;

                        end %any time match conditional
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;

                    catch
                            disp('!!!Issues in code finding any time matches');
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;

                    end
            disp('........................................')
            clear  C ia ib matchind numatch
            
            
    else %User contains '_PM' and will be matched with gpsmain2 (watch 2)
        
        %Use the start and end times of the beacon deployment
            ts = datetime(Deployment_roomcat_save.TimeMinuteRounded(1),'ConvertFrom', 'datenum');
            te = datetime(Deployment_roomcat_save.TimeMinuteRounded(end),'ConvertFrom', 'datenum');

            disp(['from ', datestr(ts), ' to ', datestr(te)]);

                    try
                        matchind = isbetween((datetime(gpsmain2.(3),'ConvertFrom', 'datenum')),ts,te);
                        numatch = sum(matchind); % number of minute matches

                        if numatch>0
                            %disp([num2str(numatch), ' time matches found']);

                            [C,ia,ib] = innerjoin(Deployment_roomcat_save,gpsmain2,'LeftKeys',[17,5],'RightKeys',[3,1]);

                            if isempty(ia)
                                nomatch = nomatch+1; %Add one to nomatch because user was not wearing the watch
                                disp('Watch not deployed with this user')%User not wearing the watch conditional
                            else
                            disp([num2str(length(ia)), ' time matches found with this user']);
                            Deployment_roomcat_save.GPS_cat(ia)= gpsmain2.dataInside(ib);
                            Deployment_roomcat_save.GPS_Buffer(ia) = gpsmain2.bufferUsed(ib);
                            Deployment_roomcat_save.GPS_flag(ia) = gpsmain2.dataflag0(ib);
                            Deployment_roomcat_save.GPS_lat(ia)=gpsmain2.latSeries(ib);
                            Deployment_roomcat_save.GPS_lon(ia)=gpsmain2.lonSeries(ib);
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;
                            end

                        else
                             disp('No data exists for the GPS watch at these times');
                             nomatch = nomatch+1;

                        end %any time match conditional
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;

                    catch
                            disp('!!!Issues in code finding any time matches');
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;

                    end
            disp('........................................')
            clear  C ia ib matchind numatch
    end
    

else % the user is from KHRC cohort
    
     %Use the start and end times of the beacon deployment
            ts = datetime(Deployment_roomcat_save.TimeMinuteRounded(1),'ConvertFrom', 'datenum');
            te = datetime(Deployment_roomcat_save.TimeMinuteRounded(end),'ConvertFrom', 'datenum');

            disp(['from ', datestr(ts), ' to ', datestr(te)]);

                    try
                        matchind = isbetween((datetime(khrcwatch1.(3),'ConvertFrom', 'datenum')),ts,te);
                        numatch = sum(matchind); % number of minute matches

                        if numatch>0
                            %disp([num2str(numatch), ' time matches found']);

                            [C,ia,ib] = innerjoin(Deployment_roomcat_save,khrcwatch1,'LeftKeys',[17,5],'RightKeys',[3,1]);

                            if isempty(ia)
                                
                                try %try watch 2
                                    matchind = isbetween((datetime(khrcwatch2.(3),'ConvertFrom', 'datenum')),ts,te);
                                    numatch = sum(matchind); % number of minute matches
                                    if numatch>0
                                       [C,ia,ib] = innerjoin(Deployment_roomcat_save,khrcwatch2,'LeftKeys',[17,5],'RightKeys',[3,1]);
                                        disp([num2str(length(ia)), ' time matches found with this user']);
                                        Deployment_roomcat_save.GPS_cat(ia)= khrcwatch2.dataInside(ib);
                                        Deployment_roomcat_save.GPS_Buffer(ia) = khrcwatch2.bufferUsed(ib);
                                        Deployment_roomcat_save.GPS_flag(ia) = khrcwatch2.dataflag0(ib);
                                        Deployment_roomcat_save.GPS_lat(ia)=khrcwatch2.latSeries(ib);
                                        Deployment_roomcat_save.GPS_lon(ia)=khrcwatch2.lonSeries(ib);
                                        Deployment_roomcat_save_temp = Deployment_roomcat_save;
                                    else
                                        nomatch = nomatch+1; %Add one to nomatch because user was not wearing the watch
                                        disp('Watch not deployed with this user')%User not wearing the watch conditional
                                    end
                                catch
                                    disp('Issue matching Kintampo participant with GPS data')
                                end
                                
                            else
                            disp([num2str(length(ia)), ' time matches found with this user']);
                            Deployment_roomcat_save.GPS_cat(ia)= khrcwatch1.dataInside(ib);
                            Deployment_roomcat_save.GPS_Buffer(ia) = khrcwatch1.bufferUsed(ib);
                            Deployment_roomcat_save.GPS_flag(ia) = khrcwatch1.dataflag0(ib);
                            Deployment_roomcat_save.GPS_lat(ia)=khrcwatch1.latSeries(ib);
                            Deployment_roomcat_save.GPS_lon(ia)=khrcwatch1.lonSeries(ib);
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;
                            end

                        else
                             disp('No data exists for either GPS watch at these times');
                             nomatch = nomatch+1;

                        end %any time match conditional
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;
                    catch
                            disp('!!!Issues in GPS code finding any time matches');
                            Deployment_roomcat_save_temp = Deployment_roomcat_save;

                    end
            disp('........................................')
            clear  C ia ib matchind numatch
end

%Smooth the GPS_cat variable as it is unlikely someone will come and go from home more than once in 30 minutes

Deployment_roomcat_save.GPS_cat = movmean(Deployment_roomcat_save.GPS_cat,30);
Deployment_roomcat_save.GPS_cat(Deployment_roomcat_save.GPS_cat>=0.5)=1;
Deployment_roomcat_save.GPS_cat(Deployment_roomcat_save.GPS_cat<0.5)=0;




end












