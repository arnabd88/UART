class fifo;
//parameter PDATA_WIDTH = 40;

int limit = 16;

typedef bit [PDATA_WIDTH-1:0] value;
value q[$];

function new (int limit);
	this.limit = limit;
endfunction

function int push_fifo (value val);
	$display ("data is %b",val); 
	if (q.size() < limit) begin
		q.push_front(val);
		return 0;
	end
	else begin
		$display ("Warning : FIFO overflow");
		return 1;
	end
endfunction

function int pop ();
	if (q.size() == 0) begin
		$display ("Warning : FIFO empty");
	end
	else begin
		value y;
		y = q.pop_back();
		return (y);
	end
endfunction

function int top ();
	return q.size();
endfunction

endclass 
