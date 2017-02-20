
<?php

class Item {
 /** @var mixed */
 public $value;

 /**
  * Содержит пары "название" => подэлемент.
  * @var Item[]
  */
 public $subItems = array();

 public function __construct($value, array $subItems = array()) {      $this->value = $value;
$this->subItems = $subItems;
 }
}

$root = new Item(10, array(
  'sub1' => new Item(11),
  'sub2' => new Item(12, array(
 'sub3' => new Item(11),
 'sub4' => new Item(15)
  )),
  'sub3' => new Item(18),
));

// printTree($root);

function printTree($item, $level = 0)
{
	echo "{$level}: {$item->value} <br/>";
	if($subItems = $item->subItems)
	{
		$level += 1;
		foreach($subItems as $subItem)
		{
			printTree($subItem, $level);
		}
	}
}


// search(Item $root, $value)

assert(search($root, 15) == '/sub2/sub4');
assert(search($root, 17) === null);
assert(search($root, 11) == '/sub1');
assert(search($root, 18) == '/sub3');
assert(search($root, 10) == '/');

function search(Item $root, $value, $path = '')
{
	if ($root->value===$value)
	{
		if($path==='') $path = '/';
		return $path;
	}

	if($subItems = $root->subItems)
	{
		//$path += 1;
		foreach($subItems as $name => $subItem)
		{
			$subPath = $path.'/'.$name;
			if($result = search($subItem, $value, $subPath))
			{
				return $result;
			}
		}
	}

	return null;
}