object RobustService: TRobustService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'RobustService'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
