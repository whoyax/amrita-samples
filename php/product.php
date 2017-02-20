<?php
class Product implements IProduct {

	private $type;
	private $id;

	private $price;
	private $discount = 0;
	private $discountPrice = null;

	public function getId()
	{
		return $this->id;
	}

	public function getPrice()
	{
		return $this->price;
	}

	public function __construct($type, $price)
	{
		$this->id = spl_object_hash($this);
		$this->type = $type;
		$this->price = $price;
	}

	public function getType()
	{
		return $this->type;
	}
}