require 'right_popen'

class Executor
  attr_accessor :status, :logger

  def initialize(opts)
    init_buff

    @opts = opts[:config]
    @logger = opts[:logger] || Logger.new(STDOUT)

    @status = :stopped
    @pid = nil
  end

  def start
    logger.info "Starting process '#{@opts[:exec]}'"
    @status = :starting
    RightScale::RightPopen.popen3_sync( 
      @opts[:exec],
      :target         => self,
      :environment    => nil,
      :pid_handler    => :on_pid,
      :stdout_handler => :on_stdout,
      :stderr_handler => :on_stderr,
      :exit_handler   => :on_exit
    )
  end

  def stop
    if @status == :running && @pid
      @status = :stopping
      logger.info 'Stopping process'
      begin
        Process.kill 'INT', @pid
      rescue Exception => e
        logger.warn "Could not stop process. {e.message}"
        @status = :running
      end
    end
  end
  
  # Return buffer, clearing in the process
  def status!
    result = @buff.dup
    init_buff
    result.merge status: @status
  end

  def init_buff
    @buff = {
      stdout: [],
      stderr: []
    }
  end

  def on_pid(pid)
    @pid = pid
    @status = :running
    logger.info "Process running. PID #{@pid}"
  end

  def on_stdout(data)
    @buff[:stdout] << data
    print data
  end

  def on_stderr(data)
    @buff[:stderr] << data
    STDERR.print data
  end

  def on_exit
    @pid = nil
    @status = :stopped
    logger.info "Process stopped"
  end
end