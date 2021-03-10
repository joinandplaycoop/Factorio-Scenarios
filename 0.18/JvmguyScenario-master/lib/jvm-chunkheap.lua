-- jvm-chunkheap.lua
--
-- this is an almost generic heap implementation.
-- what makes it not generic is that it maintains an index field
-- in heap nodes to facilitate removal from arbitrary spots in
-- the heap. 

local M={}

local function compare(a,b)
    if a.lruTime > b.lruTime then
        return 1;
    elseif a.lruTime < b.lruTime then
        return -1;
    else
        return 0;
    end
end

local function check(heap)
    for ix=0,heap.count-1 do
        if 2*ix+1 < heap.count and compare(heap.contents[ix], heap.contents[2*ix+1]) > 0 then
            game.print("foobar1");
        end
        if 2*ix+2 < heap.count and compare(heap.contents[ix], heap.contents[2*ix+2]) > 0 then
            game.print("foobar2");
        end
    end        
end


local function siftup(heap, nodeIx)
      if (nodeIx ~= 0) then
          local parentIx = math.floor((nodeIx-1)/2)
          if compare(heap.contents[parentIx], heap.contents[nodeIx])>0 then
              local temp = heap.contents[parentIx];
              heap.contents[parentIx] = heap.contents[nodeIx];
              heap.contents[parentIx].index = parentIx
              heap.contents[nodeIx] = temp;
              heap.contents[nodeIx].index = nodeIx
              siftup(heap, parentIx);
          end
      end
end

local function siftdown(heap, nodeIx)
    local minIx;
    local leftChildIx = nodeIx*2+1
    local rightChildIx = nodeIx*2+2
    if (rightChildIx >= heap.count) then
        if (leftChildIx >= heap.count) then
            return;
        else
            minIx = leftChildIx;
        end
    else
        if compare(heap.contents[leftChildIx], heap.contents[rightChildIx]) <= 0 then
            minIx = leftChildIx;
        else
            minIx = rightChildIx;
        end
    end
    if compare(heap.contents[nodeIx], heap.contents[minIx])> 0 then
        local tmp = heap.contents[minIx];
        heap.contents[minIx] = heap.contents[nodeIx];
        heap.contents[minIx].index = minIx;
        heap.contents[nodeIx] = tmp;
        heap.contents[nodeIx].index = nodeIx;
        siftdown(heap, minIx);
    end
end

function M.new(compareFunc)
    local f = compareFunc
    if (f == nil) then
        f = compare
    end
    return { contents={}, compare=f, count=0 }
end

function M.insert(heap, item)
    -- game.print("insert: " .. item.index .. " count=" .. heap.count)
	heap.contents[heap.count] = item
	item.index = heap.count
	heap.count = heap.count + 1
	siftup(heap, heap.count-1)
	-- check(heap)
end

function M.remove(heap, item)
    -- log("remove: " .. item.index .. " count=" .. heap.count)
	if heap.count>0 then	
        local index = item.index;
        if heap.count>1 then
    	   heap.contents[index] = heap.contents[heap.count-1]
    	    heap.contents[index].index = index
    	end
    	heap.count = heap.count - 1
    	if heap.count>index then
		  siftdown(heap, index)
    	end
    -- check(heap)
    end
end 

function M.head(heap)
    -- game.print("head: " .. heap.count)
    if heap.count>0 then
	   return heap.contents[0]
    end
    return nil;
end

function M.size(heap)
    return heap.count;
end

M.compare = compare
M.check = check

return M;

