unit rmxQueueRequests;

interface

uses
  SysUtils, Classes, Generics.Collections, SyncObjs;

type
  /// <summary>Simple Threaded Queue</summary>
  TSimpleRequestExecute<T> = procedure (Const aThread:TThread;Const RequestsCount:Integer;Const aRequest:T) of Object;

  /// <summary>Simple Threaded Queue</summary>
  TSimpleRequestAnswer<T> = procedure (Const aRequest:T) of Object;

  /// <summary>Simple Threaded Queue</summary>
  TSimpleRequestProgress = procedure (Const aMsg:String) of Object;

  /// <summary>Simple Threaded Queue</summary>
  TSimpleThreadedQueue<T> = class
  strict private
    FQueue: TQueue<T>;
    FClosed: Boolean;

  public
    /// <summary>constructor</summary>
    constructor Create;
    /// <summary>destructor</summary>
    destructor Destroy; override;

    /// <summary>Enqueue</summary>
    function Enqueue(const Item: T;Const Timeout: LongWord = INFINITE): TWaitResult;
    /// <summary>Dequeue</summary>
    function Dequeue(Var ItemCount:Integer;var Item: T;Const Timeout: LongWord = INFINITE): TWaitResult;
    /// <summary>Close</summary>
    procedure Close;

    property Closed: Boolean read FClosed;
  end;

  /// <summary>Simple Queue Requests</summary>
  TSimpleBackgroundRequests<T> = class
  protected
    FInQueue,
    FOutQueue     : TSimpleThreadedQueue<T>;
    FProgressQueue: TSimpleThreadedQueue<String>;
    FThreadsActive: TCountdownEvent;
    fOnExecute    : TSimpleRequestExecute<T>;
    fOnAnswer     : TSimpleRequestAnswer<T>;
    fOnProgress   : TSimpleRequestProgress;
    /// <summary>Poll to dequeue Progress</summary>
    ///  will fire OnAnswer Event ! MUST be called to get answer
    procedure PollProgress;

  protected
    /// <summary>Start Thread</summary>
    procedure StartThread;virtual;

  public
    /// <summary>constructor</summary>
    constructor Create;
    /// <summary>destructor</summary>
    destructor Destroy; override;

    /// <summary>Fire Request</summary>
    procedure FireRequest(const Item: T);

    /// <summary>Poll to dequeue Progress,Answer</summary>
    ///  will fire OnAnswer Event ! MUST be called to get answer
    procedure Poll;

    property OnExecute : TSimpleRequestExecute<T> read fOnExecute   write fOnExecute;
    property OnAnswer  : TSimpleRequestAnswer<T>  read fOnAnswer    write fOnAnswer;
    property OnProgress: TSimpleRequestProgress   read fOnProgress  write fOnProgress;
  end;

implementation

uses Diagnostics;

{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TSimpleThreadedQueue<T>.Create;
begin
  inherited Create;
  FQueue := TQueue<T>.Create;
end;
{______________________________________________________________________________}
destructor TSimpleThreadedQueue<T>.Destroy;
begin
  Self.Close;
  fQueue.Free;
  inherited Destroy;
end;
{______________________________________________________________________________}
procedure TSimpleThreadedQueue<T>.Close;
begin
  if FClosed then
    Exit;

  fClosed := True;
  TMonitor.Enter(FQueue);
  try
      FQueue.Clear;
      TMonitor.PulseAll(FQueue); //notify any waiters Closed is now True
  finally
      TMonitor.Exit(FQueue);
  end;
end;
{______________________________________________________________________________}
function TSimpleThreadedQueue<T>.Enqueue(const Item: T;Const Timeout: LongWord): TWaitResult;
begin
  if Closed then
    Exit(wrAbandoned);

  if not TMonitor.Enter(FQueue, Timeout) then
    Exit(wrTimeout);

  try if Closed then
        Exit(wrAbandoned);
      FQueue.Enqueue(Item);
      TMonitor.Pulse(FQueue);
      Result := wrSignaled;
  finally
      TMonitor.Exit(FQueue);
  end;
end;
{______________________________________________________________________________}
function TSimpleThreadedQueue<T>.Dequeue(Var ItemCount:Integer;var Item: T;Const Timeout: LongWord): TWaitResult;
var Stopwatch: TStopwatch;
    TimeoutLeft: Int64;
begin
  Stopwatch := TStopwatch.StartNew;

  if Closed then
    Exit(wrAbandoned);

  if not TMonitor.Enter(FQueue, Timeout) then
    Exit(wrTimeout);
  try
      while (not Closed) and (FQueue.Count = 0) do begin
        TimeoutLeft := Timeout - Stopwatch.ElapsedMilliseconds;
        if TimeoutLeft < 0 then
          TimeoutLeft := 0;
        if not TMonitor.Wait(FQueue, LongWord(TimeoutLeft)) then Begin
          Exit(wrTimeout);
        end end;
      if Closed then Begin
        Exit(wrAbandoned);
        end;
      ItemCount := FQueue.Count;
      Item := FQueue.Dequeue;
      Result := wrSignaled;
  finally
      TMonitor.Exit(FQueue);
  end;
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TSimpleBackgroundRequests<T>.Create;
begin
  inherited Create;

  FInQueue := TSimpleThreadedQueue<T>.Create;
  FOutQueue := TSimpleThreadedQueue<T>.Create;
  FProgressQueue:= TSimpleThreadedQueue<String>.Create;

  //has to be at least 1
  FThreadsActive := TCountdownEvent.Create(1);

  //Create and Start Thread
  StartThread;
end;
{______________________________________________________________________________}
destructor TSimpleBackgroundRequests<T>.Destroy;
begin
  FInQueue.Close;

  //release our 1
  FThreadsActive.Signal;
  //wait for the worker threads to terminate
  FThreadsActive.WaitFor;
  FThreadsActive.Free;

  FProgressQueue.Free;
  FOutQueue.Free;
  FInQueue.Free;

  inherited
end;
{______________________________________________________________________________}
procedure TSimpleBackgroundRequests<T>.StartThread;
Begin
  TThread.CreateAnonymousThread(
      procedure
      var ThreadID: TThreadID;
          ItemCount : Integer;
          S: T;
      begin
        FThreadsActive.AddCount;
        try
            ThreadID := TThread.CurrentThread.ThreadID;
            FProgressQueue.Enqueue(Format(  'Thread %d is starting', [ThreadID]));
            while FInQueue.Dequeue(ItemCount,S) = wrSignaled do begin
              FProgressQueue.Enqueue(Format('Dequeued 1 of %d (thread %d)', [ItemCount,ThreadID]));
              if Assigned(fOnExecute) then
                fOnExecute(TThread.CurrentThread,ItemCount,S);
              FProgressQueue.Enqueue(Format('..Finished processing (thread %d)',[ThreadID]));
              FOutQueue.Enqueue(S);
              end;
            FProgressQueue.Enqueue(Format(    'Thread %d is terminating', [ThreadID]));
        finally
          FThreadsActive.Signal;
        end;
      end
      ).Start;
End;
{______________________________________________________________________________}
procedure TSimpleBackgroundRequests<T>.FireRequest(const Item: T);
Begin
  FInQueue.Enqueue(Item);
End;
{______________________________________________________________________________}
procedure TSimpleBackgroundRequests<T>.PollProgress;
Var ItemCount:Integer;
    Msg:String;
Begin
  //drain the out queue but don't wait on it
  while FProgressQueue.Dequeue(ItemCount,Msg, 0) = wrSignaled do begin
    if Assigned(fOnProgress) then
      fOnProgress(Msg);
    end;
End;
{______________________________________________________________________________}
procedure TSimpleBackgroundRequests<T>.Poll;
Var ItemCount:Integer;
    Msg:String;
    S:T;
Begin
  PollProgress;
  //drain the out queue but don't wait on it
  while FOutQueue.Dequeue(ItemCount,S,0) = wrSignaled do begin
    if Assigned(fOnAnswer) then
      fOnAnswer(S);
    PollProgress;
    end;
End;

end.
